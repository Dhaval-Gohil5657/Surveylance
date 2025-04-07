import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Authentication/login.dart';
import 'package:surveylance/Citizen/citizen_dash.dart';
import 'package:surveylance/Leader/leader_dash.dart';
import 'package:surveylance/Member/member_dash.dart';
import 'package:surveylance/screens/on_boarding.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    chechUserLoginStatus();
  }

    Future<void> chechUserLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));
    String? token = await storage.read(key: "auth_token");
    String? role = await storage.read(key: "user_role");

    if (token != null && role != null) {
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Onboarding()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        color: Colors.white,

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset('images/surveylance.png'),
              ),
              SizedBox(height: 30),
              // Text(
              //   'Surveylance',
              //   style: TextStyle(
              //     color: taskcolor,
              //     fontSize: 35,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: -1.5
              //   ),
              // ),
              // SizedBox(
              //   width: 230,
              //   child: Image.asset('images/survtext.png')),
            ],
          ),
        ),
      ),
    );
  }
}
