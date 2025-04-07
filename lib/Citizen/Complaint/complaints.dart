import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/Complaint/add_complain.dart';
import 'package:surveylance/Citizen/Complaint/c_model.dart';
import 'package:surveylance/Citizen/Complaint/view_complain.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/url.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<Complaint> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      String? authToken = await storage.read(key: "auth_token");
      final uri = Uri.parse("$baseurl/surv/searchComplaintsCitizen");

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data']['complaints'];
          setState(() {
            complaints = data.map((e) => Complaint.fromJson(e)).toList();
            isLoading = false;
          });
        }
      } else {
        print("Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _navigateToAddComplain() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddComplain()),
    );

    if (shouldRefresh == true) {
      fetchComplaints(); // Refresh complaints list
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
          'Complaints',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToAddComplain,
            icon: Icon(Icons.assignment_add, color: Colors.white, size: 30),
          ),
          SizedBox(width: 10),
        ],
      ),
      body:
          isLoading
              ? CustomLoader(color: appcolor)
              : complaints.isEmpty
              ? Center(
                child: Text(
                  'File Complaint',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              )
              : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final c = complaints[index];

                  String formattedDate =
                      "${c.createdAt.day}-${c.createdAt.month}-${c.createdAt.year}";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewComplain(complaint: c,
                          date: formattedDate,),
                        ),
                      );
                    },
                    child: complaint(
                      c.title,
                      'Send',
                      c.description,
                      formattedDate,
                    ),
                  );
                },
              ),
    );
  }

  Widget complaint(
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
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(fontSize: 11.5),
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
              SizedBox(width: 5),
              Text(time, style: TextStyle(fontSize: 11.5)),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
