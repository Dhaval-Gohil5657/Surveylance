import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Authentication/login.dart';
import 'package:surveylance/Widgets/toast.dart';

void logOut(BuildContext context) {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> navigateToLogin(BuildContext context) async {
    Future.delayed(Duration(seconds: 1));
    await storage.delete(key: "auth_token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false,
    );
  }

  // Future<void> logout() async {
  //   String? authToken = await storage.read(key: "auth_token");

  //   if (authToken == null) {
  //     print("⚠️ No Auth Token Found! Already logged out.");
  //     navigateToLogin(context);
  //     return;
  //   }

  //   final url = Uri.parse(
  //       "https://bill-management-system-typescript.onrender.com/logout");

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Authorization": "Bearer $authToken",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print("✅ Logout successful!");
  //       navigateToLogin(context);
  //     } else {
  //       showToast(message: "Logout Failed");
  //       print("❌ Logout failed: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("⚠️ Error during logout: $e");
  //   }
  // }

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: gridcolor,
            title: Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w500, color: appcolor),
            ),
            content: Text(
              "Are you sure you want to Logout?",
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "No",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Future.delayed(Duration(microseconds: 300));
                  showToast(message: 'Logging out...');
                  navigateToLogin(context);
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appcolor),
                ),
              )
            ]);
      });
}

