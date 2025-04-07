import 'package:flutter/material.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/Complaint/complaints.dart';
import 'package:surveylance/Citizen/event.dart';
import 'package:surveylance/Citizen/notifications.dart';
import 'package:surveylance/Citizen/Request/requests.dart';
import 'package:surveylance/Sidebar/sidebar.dart';

class CitizenDash extends StatefulWidget {
  const CitizenDash({super.key});

  @override
  State<CitizenDash> createState() => _CitizenDashState();
}

class _CitizenDashState extends State<CitizenDash> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () async {
        bool exitApp = await _showExitDialog(context);
        return exitApp; 
      },
      child: Scaffold(
        drawer: Sidebar(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: appcolor,
          title: Text(
            'Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => Notifications()),
          //       );
          //     },
          //     icon: Icon(Icons.notifications_outlined, color: Colors.white),
          //   ),
          // ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Expanded(
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    children: [
                      GridTile(
                        child: gridCard(
                          Icons.assignment,
                          'Complaint',
                          'File a complaint about local sanitation or garbage collection',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Complaints(),
                              ),
                            );
                          },
                        ),
                      ),
                      GridTile(
                        child: gridCard(
                          Icons.live_help,
                          'Request',
                          'Make a special request to get your recyclables collected.',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Requests()),
                            );
                          },
                        ),
                      ),
                      GridTile(
                        child: gridCard(
                          Icons.calendar_month_rounded,
                          'Events',
                          'join events focused on cleanliness and sanitation. ',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Event()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget gridCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: gridcolor,
        shadowColor: gridcolor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: appcolor, size: 30),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: true, 
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text("Exit App",style: TextStyle(color: appcolor,fontWeight: FontWeight.w500),),
                content: Text("Are you sure you want to exit?",style: TextStyle(color: Colors.black),),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.of(context).pop(false),
                    child: Text("Cancel",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w500,fontSize: 15)),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.of(context).pop(true),
                    child: Text("Exit",style: TextStyle(color: appcolor,fontWeight: FontWeight.w500,fontSize: 16)),
                  ),
                ],
              ),
        ) ??
        false; 
  }
}
