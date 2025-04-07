import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/citizen_dash.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _CreateState();
}

class _CreateState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final FlutterSecureStorage storage = FlutterSecureStorage();
  // final String baseurl = "http://192.168.1.13:5000";
  // final String baseurl = "https://bill-management-system-typescript.onrender.com";

  bool issigning = false;
  bool isselected = true;
  bool isselected1 = true;

  Future<void> saveToken(String token) async {
    await storage.write(key: "auth_token", value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: "auth_token");
  }

  Future<void> create() async {
    // if (emailController.text.trim().isEmpty ||
    //     userNameController.text.trim().isEmpty ||
    //     phoneNoController.text.trim().isEmpty ||
    //     passwordController.text.trim().isEmpty ||
    //     confirmPasswordController.text.trim().isEmpty) {
    //   showToast(message: 'Please fill all the details');
    //   return;
    // }
    // if (passwordController.text.trim() !=
    //     confirmPasswordController.text.trim()) {
    //   showToast(message: 'Passwords do not match');
    //   return;
    // }
    // if (passwordController.text.length < 4) {
    //   showToast(message: 'Password must be at least 4 characters long');
    //   return;
    // }

    setState(() {
      issigning = true;
    });

    final url = Uri.parse("$baseurl/surv/registration");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // "firstName": firstNameController.text.trim(),
          // "lastName": lastNameController.text.trim(),
          "userName": userNameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "phoneNo": phoneNoController.text.trim(),
          "state": stateController.text.trim(),
          "city": cityController.text.trim(),
          "location": locationController.text.trim(),
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);
      print("Parsed Data: $data");

      if (response.statusCode == 201) {
        if (data["data"] != null && data["data"]["token"] != null) {
          String token = data["data"]["token"];
          print("Token Found: $token");

          await saveToken(token);
          showToast(message: 'Registration successful');

          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CitizenDash()),
            );
          });
        } else {
          print("Error: Token not found in response");
        }
      } else {
        showToast(
          message: "Registration failed: ${data['message'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      print('Error: $e');
      showToast(message: 'An error occurred. Please try again.');
    }

    setState(() {
      issigning = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
        "Location permissions are permanently denied. Go to settings to enable.",
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        stateController.text = place.administrativeArea ?? ""; // State
        cityController.text = place.locality ?? ""; // City
        locationController.text =
            "${place.street}, ${place.subLocality}, ${place.locality}"; // Location
      }
    } catch (e) {
      print("Error getting location: $e");
    }
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
            padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REGISTER',
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
                SizedBox(height: 25),
                Text(
                  'Please register with your details to access',
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
                SizedBox(height: 20),
                textField(
                  userNameController,
                  Icons.alternate_email,
                  'Username',
                  16,
                ),
                SizedBox(height: 8),
                textField(emailController, Icons.email, 'Email', 30),
                SizedBox(height: 8),
                _phoneNumberField(phoneNoController),
                SizedBox(height: 8),
                textField(
                  stateController,
                  Icons.location_pin,
                  'State',
                  20,
                  isLocationField: true,
                ),
                SizedBox(height: 8),
                textField(cityController, Icons.location_pin, 'City', 20),
                SizedBox(height: 8),
                textField(
                  locationController,
                  Icons.near_me_rounded,
                  'Area',
                  80,
                ),
                SizedBox(height: 8),
                _passwordField(passwordController, 'Password'),
                SizedBox(height: 8),
                _confirmpasswordField(
                  confirmPasswordController,
                  'Confirm Password',
                ),
                SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height / 2.7,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          issigning
                              ? CustomLoader(color: Colors.white)
                              : Text(
                                'REGISTER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
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

  Widget textField(
    TextEditingController controller,
    IconData icon,
    String label,
    int? length, {
    bool isLocationField = false,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          TextField(
            cursorColor: appcolor,
            style: TextStyle(fontSize: 14),
            maxLength: length,
            controller: controller,
            decoration: InputDecoration(
              counterText: '',
              labelText: label,
              labelStyle: TextStyle(color: appcolor, fontSize: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appcolor, width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appcolor, width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(icon, color: appcolor),
              suffixIcon:
                  isLocationField
                      ? IconButton(
                        icon: Icon(Icons.my_location, color: appcolor),
                        onPressed: _getCurrentLocation, // Fetch live location
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, label) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: TextField(
        cursorColor: appcolor,
        style: TextStyle(fontSize: 14),
        obscureText: isselected,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: appcolor, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appcolor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appcolor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.lock, color: appcolor),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                isselected = !isselected;
              });
            },
            icon:
                isselected
                    ? Icon(Icons.visibility_off, color: appcolor, size: 20)
                    : Icon(Icons.visibility, color: appcolor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _confirmpasswordField(TextEditingController controller, label) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: TextField(
        cursorColor: appcolor,
        style: TextStyle(fontSize: 14),
        obscureText: isselected1,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: appcolor, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appcolor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appcolor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.lock, color: appcolor),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                isselected1 = !isselected1;
              });
            },
            icon:
                isselected1
                    ? Icon(Icons.visibility_off, color: appcolor, size: 20)
                    : Icon(Icons.visibility, color: appcolor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _phoneNumberField(TextEditingController controller) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: TextField(
        cursorColor: appcolor,
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.number,
        maxLength: 10,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        controller: controller,
        decoration: InputDecoration(
          labelText: "Phone no",
          labelStyle: TextStyle(color: appcolor, fontSize: 14),
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appcolor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appcolor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.phone, color: appcolor),
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
