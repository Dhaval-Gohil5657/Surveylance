import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Authentication/Forgot%20password/forgot_password.dart';
import 'package:surveylance/Authentication/register.dart';
import 'package:surveylance/Citizen/citizen_dash.dart';
import 'package:surveylance/Leader/leader_dash.dart';
import 'package:surveylance/Member/member_dash.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/Widgets/toast.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/url.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController loginFieldController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool issigning = false;
  bool isselected = true;

  Future<void> saveToken(String token) async {
    await storage.write(key: "auth_token", value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: "auth_token");
  }

 Future<void> login() async {
  if (loginFieldController.text.trim().isEmpty ||
      passwordController.text.trim().isEmpty) {
    showToast(message: 'Please fill in all the details');
    return;
  }

  setState(() {
    issigning = true;
  });

  final roles = ['citizen', 'leader', 'member'];
  
  bool success = false;

  for (String role in roles) {
    final url = Uri.parse("$baseurl/surv/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "loginField": loginFieldController.text.trim(),
          "password": passwordController.text.trim(),
          "role": role,
        }),
      );

      await storage.write(key: "user_role", value: role);


      print("Trying role: $role -> Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data["data"] != null && data["data"]["token"] != null) {
          String token = data["data"]["token"];

          // 👇 Use actualRole if available
          String userRole = data["data"]["actualRole"] ?? data["data"]["role"] ?? role;

          print("✅ Login successful as $userRole");
          await saveToken(token);
          showToast(message: 'Login successful');

          _navigateToRoleBasedScreen(userRole);
          success = true;
          break;
        }
      }
    } catch (e) {
      print("Error while trying role $role: $e");
    }
  }

  if (!success) {
    showToast(message: 'Login failed. Please check your credentials.');
  }

  setState(() {
    issigning = false;
  });
}

void _navigateToRoleBasedScreen(String role) {
  Widget nextScreen;

  switch (role.toLowerCase()) {
    case "leader":
      nextScreen = LeaderDash();
      break;
    case "member":
      nextScreen = MemberDash();
      break;
    case "citizen":
    default:
      nextScreen = CitizenDash();
      break;
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => nextScreen),
    (Route<dynamic> route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, gridcolor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: appcolor,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  width: 70,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: appcolor,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Please sign in with your credentials to access',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Surveylance.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40),
                Card(
                  color: Colors.white,
                  shadowColor: Colors.white,
                  child: TextField(
                    controller: loginFieldController,
                    cursorColor: appcolor,
                    decoration: InputDecoration(
                      label: Text(
                        'Username or Email',
                        style: TextStyle(color: appcolor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appcolor, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appcolor, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      prefixIcon: Icon(Icons.alternate_email, color: appcolor),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  shadowColor: Colors.white,
                  child: TextField(
                    cursorColor: appcolor,
                    obscureText: isselected,
                    controller: passwordController,
                    decoration: InputDecoration(
                      label: Text(
                        'Password',
                        style: TextStyle(color: appcolor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appcolor, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appcolor, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.key, color: appcolor),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isselected = !isselected;
                          });
                        },
                        icon:
                            isselected
                                ? Icon(
                                  Icons.visibility_off,
                                  color: appcolor,
                                  size: 20,
                                )
                                : Icon(
                                  Icons.visibility,
                                  color: appcolor,
                                  size: 20,
                                ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: gridcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        context: context,
                        builder: (context) => ForgotPassword(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: appcolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.08,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: appcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        issigning
                            ? CustomLoader(color: Colors.white)
                            : Text(
                              'LOG IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.black54)),
                    SizedBox(width: 30),
                    Text(
                      'OR',
                      style: TextStyle(
                        color: appcolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 30),
                    Expanded(child: Divider(color: Colors.black54)),
                  ],
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.08,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: appcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'REGISTER AS CITIZEN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
