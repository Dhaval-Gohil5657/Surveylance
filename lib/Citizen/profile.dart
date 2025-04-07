import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Widgets/loader.dart';
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = false;
  bool isEditMode = false;
  String userRole = "";

  final _formKey = GlobalKey<FormState>();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserRole();
    _fetchUserProfile();
  }

  Future<void> getUserRole() async {
    String? role = await storage.read(key: "user_role");
    setState(() {
      userRole = role ?? "";
    });
  }

  Future<void> _fetchUserProfile() async {
    final profileUrl = Uri.parse("$baseurl/surv/getCitizenProfile");
    setState(() => isLoading = true);

    try {
      String? authToken = await storage.read(key: "auth_token");

      final response = await http.post(
        profileUrl,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData = data["data"];

        userNameController.text = userData?["userName"] ?? '';
        firstNameController.text = userData?["firstName"] ?? '';
        lastNameController.text = userData?["lastName"] ?? '';
        phoneNoController.text = userData?["phoneNo"] ?? '';
        emailController.text = userData?["email"] ?? '';
        stateController.text = userData?["state"] ?? '';
        cityController.text = userData?["city"] ?? '';
        locationController.text = userData?["location"] ?? '';
      }
    } catch (e) {
      print('Fetch error: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    final updateUrl = Uri.parse("$baseurl/surv/updateCitizenProfile");

    final updatedData = {
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "phoneNo": phoneNoController.text.trim(),
      "email": emailController.text.trim(),
      "state": stateController.text.trim(),
      "city": cityController.text.trim(),
      "location": locationController.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      String? authToken = await storage.read(key: "auth_token");

      final response = await http.post(
        updateUrl,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      final data = jsonDecode(response.body);
      print(data); // 👈 to inspect the actual structure

      // Check if data["data"] is a Map or List
      if (data["data"] is Map<String, dynamic>) {
        userData = data["data"];
      } else if (data["data"] is List && data["data"].isNotEmpty) {
        userData = data["data"][0]; // if it’s a list, take first item
      }

      if (response.statusCode == 200) {
        showToast(message: "Profile updated successfully");
        await _fetchUserProfile();
        setState(() => isEditMode = false);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${data['message']}")));
      }
    } catch (e) {
      print('Update error: $e');
    }

    setState(() => isLoading = false);
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
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (isEditMode) {
                if (_formKey.currentState?.validate() ?? false) {
                  _updateProfile();
                }
              } else {
                setState(() => isEditMode = true);
              }
            },
            icon: Icon(
              isEditMode ? Icons.done_outline : Icons.edit_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body:
          isLoading
              ? Center(child: CustomLoader(color: appcolor))
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      profileField(
                        Icons.alternate_email,
                        userNameController,
                        'User Name',
                        editable: false,
                      ),
                      profileField(
                        Icons.person_4,
                        firstNameController,
                        'First Name',
                      ),
                      profileField(
                        Icons.person,
                        lastNameController,
                        'Last Name',
                      ),
                      profileField(
                        Icons.phone_android,
                        phoneNoController,
                        'Phone No.',
                      ),
                      profileField(Icons.email, emailController, 'Email'),
                      if(userRole.toLowerCase() == "citizen")
                      Column(
                        children: [
                          profileField(
                            Icons.location_pin,
                            stateController,
                            'State',
                          ),
                          profileField(Icons.location_pin, cityController, 'City'),
                          profileField(
                            Icons.near_me_rounded,
                            locationController,
                            'Location',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget profileField(
    IconData icon,
    TextEditingController controller,
    String labelText, {
    bool editable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shadowColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: appcolor),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(icon, color: appcolor, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child:
                            editable && isEditMode
                                ? TextFormField(
                                  cursorColor: appcolor,
                                  controller: controller,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter $labelText';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration.collapsed(
                                    hintText: labelText,
                                  ),
                                )
                                : Text(
                                  controller.text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  labelText,
                  style: TextStyle(
                    color: appcolor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
