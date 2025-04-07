import 'package:flutter/material.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Authentication/Forgot%20password/forgot_password_api.dart';
import 'package:surveylance/Widgets/loader.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  void _sendResetPassword() async {
    setState(() {
      isLoading = true;
    });

    final result = await forgotPassword(emailController.text);

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      Navigator.of(context).pop();
    }
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
              "Forget Password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: appcolor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Enter your email to receive a reset password.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 0.1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                cursorColor: appcolor,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: appcolor),
                  prefixIcon: Icon(Icons.email, size: 20, color: appcolor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appcolor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appcolor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: isLoading ? null : _sendResetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child:
                      isLoading
                          ? CircularProgressIndicator(color: appcolor,)
                          : Text(
                            "Send",
                            style: TextStyle(
                              fontSize: 18,
                              color: appcolor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
