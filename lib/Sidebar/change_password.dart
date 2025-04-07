import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool isUpdating = false;

  Future<void> _changePassword() async {
    setState(() => isUpdating = true);

    final changePasswordUrl = Uri.parse("$baseurl/surv/changePassword");
    String? authToken = await storage.read(key: "auth_token");

    final body = jsonEncode({
      "currentPassword": currentPasswordController.text,
      "newPassword": newPasswordController.text,
    });

    try {
      final response = await http.post(
        changePasswordUrl,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      final responseData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200 && responseData["success"] == true) {
        showToast(message: "Password changed successfully");
        Navigator.pop(context);
      } else {
        showToast(message: "${responseData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      showToast(message: "$e");
    }

    setState(() => isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Change Password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: appcolor,
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 0.1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                cursorColor: appcolor,
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: 20, color: appcolor),
                  labelText: "Current Password",
                  labelStyle: TextStyle(color: Colors.black54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appcolor, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appcolor, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white,
              elevation: 0.1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                cursorColor: appcolor,
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key, size: 20, color: appcolor),
                  labelText: "New Password",
                  labelStyle: TextStyle(color: Colors.black54),

                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appcolor, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appcolor, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isUpdating ? null : _changePassword,
                  child:
                      isUpdating
                          ? CircularProgressIndicator(color: appcolor)
                          : Text(
                            "Change",
                            style: TextStyle(
                              fontSize: 18,
                              color: appcolor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
