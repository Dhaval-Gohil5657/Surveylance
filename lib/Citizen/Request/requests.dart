import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/Request/r_model.dart';
import 'package:surveylance/Citizen/Request/send_request.dart';
import 'package:surveylance/Citizen/Request/view_request.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/url.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<RequestModel> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequest();
  }

  Future<void> fetchRequest() async {
    try {
      String? authToken = await storage.read(key: "auth_token");
      final uri = Uri.parse("$baseurl/surv/searchRequestsCitizen");

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data']['requests'];
          setState(() {
            requests = data.map((e) => RequestModel.fromJson(e)).toList();
            isLoading = false;
          });
        }
      } else {
        print("Failed to fetch request: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _navigateToAddRequest() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendRequest()),
    );

    if (shouldRefresh == true) {
      fetchRequest(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appcolor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        title: Text(
          'Requests',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToAddRequest,
            icon: Icon(Icons.send_outlined, color: Colors.white, size: 25),
          ),
          SizedBox(width: 10),
        ],
      ),
      body:
          isLoading
              ? CustomLoader(color: appcolor)
              : requests.isEmpty
              ? Center(
                child: Text(
                  'Send Request',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              )
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final r = requests[index];
                  String formattedDate =
                      "${r.createdAt.day}-${r.createdAt.month}-${r.createdAt.year}";
                  return GestureDetector(
                    onTap: (){
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRequest(request: r,
                          ),
                        ),
                      );
                    },
                    child: request(r.title, 'Send', r.description, formattedDate));
                },
              ),
    );
  }

  Widget request(
    String title,
    String isAssign,
    String description,
    // String location,
    String time,
  ) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
      color: Colors.white,
      shadowColor: Colors.white,
      elevation: 1.5,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: taskcolor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 3,
                bottom: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Card(
                    elevation: 0,
                    color: appcolor,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 6,
                        right: 6,
                        top: 3,
                        bottom: 3,
                      ),
                      child: Text(
                        isAssign,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              SizedBox(width: 5),
              Icon(Icons.short_text_rounded, color: appcolor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Divider(color: taskcolor, thickness: 0.5),
          ),
          Row(
            children: [
              SizedBox(width: 5),
              Icon(Icons.date_range_outlined, color: appcolor, size: 18),
              SizedBox(width: 10),
              Text(time, style: TextStyle(fontSize: 11)),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
