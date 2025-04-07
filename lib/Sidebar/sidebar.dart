import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Authentication/logout.dart';
import 'package:surveylance/Citizen/profile.dart';
import 'package:surveylance/Sidebar/about.dart';
import 'package:surveylance/Sidebar/change_password.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String userRole = "";

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    String? role = await storage.read(key: "user_role");
    setState(() {
      userRole = role ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 250,
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle, color: appcolor, size: 35),
            title: Text(
              'View Profile',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            trailing: Icon(Icons.keyboard_arrow_right_rounded, color: appcolor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),

          Divider(color: appcolor, thickness: 1.5),
          ListTile(
            leading: Icon(Icons.key, color: appcolor),
            title: Text(
              'Change password',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                backgroundColor: gridcolor,
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => ChangePasswordBottomSheet(),
              );
            },
          ),
          if (userRole.toLowerCase() == "leader")
            ListTile(
              leading: Icon(Icons.person_add_alt_1, color: appcolor),
              title: Text(
                'Add Member',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              onTap: () {},
            ),

          ListTile(
            leading: Icon(Icons.share, color: appcolor),
            title: Text(
              'Share app',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: appcolor),
            title: Text(
              'Log out',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onTap: () => logOut(context),
          ),
          if (userRole.toLowerCase() == "citizen")
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: appcolor),
              title: Text(
                'About',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                );
              },
            ),
        ],
      ),
    );
  }
}
