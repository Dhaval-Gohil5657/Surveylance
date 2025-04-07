import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/Request/r_model.dart';
import 'package:surveylance/Leader/Requests/rtl_model.dart';
import 'package:surveylance/Leader/Requests/view_request_tl.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/url.dart';

class RequestTl extends StatefulWidget {
  const RequestTl({super.key});

  @override
  State<RequestTl> createState() => _RequestTlState();
}

class _RequestTlState extends State<RequestTl> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<RequestTlModel> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequest();
  }

  Future<void> fetchRequest() async {
    try {
      String? authToken = await storage.read(key: "auth_token");
      final uri = Uri.parse("$baseurl/surv/searchRequestsLeader");

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
            requests = data.map((e) => RequestTlModel.fromJson(e)).toList();
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
      ),
      body:
          isLoading
              ? CustomLoader(color: appcolor)
              : requests.isEmpty
              ? Center(
                child: Text(
                  'No any Request',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              )
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final r = requests[index];
                  String formattedDate =
                      "${r.createdAt?.day}-${r.createdAt?.month}-${r.createdAt?.year}";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRequestTl(requests: r),
                        ),
                      );
                    },
                    child: request(
                      r.title,
                      'Received',
                      r.description,
                      r.location,
                    ),
                  );
                },
              ),
    );
  }

  Widget request(
    String title,
    String isAssign,
    String description,
    String location,
    // String time,
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
              Icon(Icons.near_me_rounded, color: appcolor, size: 18),
              SizedBox(width: 10),
              Text(location, style: TextStyle(fontSize: 11)),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
