import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Leader/Events/add_event.dart';
import 'package:surveylance/Leader/Events/e_model.dart';
import 'package:surveylance/Member/Events/add_event_tm.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/url.dart';

class EventTm extends StatefulWidget {
  const EventTm({super.key});

  @override
  State<EventTm> createState() => _EventTmState();
}

class _EventTmState extends State<EventTm> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<EventModel> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchevents();
  }

  Future<void> fetchevents() async {
    try {
      String? authToken = await storage.read(key: "auth_token");
      final uri = Uri.parse("$baseurl/surv/getEvents");

      final response = await http.get(
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
          List<dynamic> data = jsonData['data']['events'];
          setState(() {
            events = data.map((e) => EventModel.fromJson(e)).toList();
            isLoading = false;
          });
        }
      } else {
        print("Failed to fetch event: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _navigateToAddEvent() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventTm()),
    );

    if (shouldRefresh == true) {
      fetchevents();
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
          'Events',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToAddEvent,
            icon: Icon(Icons.event, color: Colors.white, size: 28),
          ),
          SizedBox(width: 10),
        ],
      ),
      body:
          isLoading
              ? CustomLoader(color: appcolor)
              : events.isEmpty
              ? Center(
                child: Text(
                  'Add Event',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              )
              : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final e = events[index];
                  return event(e.title, e.description, e.location, e.date);
                },
              ),
    );
  }

  Widget event(String title, String description, String location, String date) {
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
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                      top: 3,
                      bottom: 3,
                    ),
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.parse(date)),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
              Icon(Icons.location_pin, color: appcolor, size: 18),
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
