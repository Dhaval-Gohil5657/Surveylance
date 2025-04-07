import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

class AddComplain extends StatefulWidget {
  const AddComplain({super.key});

  @override
  State<AddComplain> createState() => _AddComplainState();
}

class _AddComplainState extends State<AddComplain> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController houseNoController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController complaintTypeController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isSending = false;

  /// **Function to pick image from camera or gallery**
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadComplaint() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        locationController.text.isEmpty ||
        complaintTypeController.text.isEmpty) {
      showToast(message: "Please fill all the details");
      return;
    }

    if (_selectedImage == null) {
      showToast(message: "Please select an image");
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      String? authToken = await storage.read(key: "auth_token");
      String uploadUrl = "$baseurl/surv/uploadComplaint";
      final uri = Uri.parse(uploadUrl);
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $authToken';

      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['location'] = locationController.text.trim();
      request.fields['houseNo'] = houseNoController.text.trim();
      request.fields['complaintType'] = complaintTypeController.text.trim();

      request.files.add(
        await http.MultipartFile.fromPath(
          'complaintFile',
          _selectedImage!.path, // now safe to use
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          String complaintId = jsonResponse['data']['complaint']['_id'];
          await storage.write(key: "last_uploaded_Id", value: complaintId);
          showToast(message: "Complaint uploaded successfully");
          Navigator.pop(context, true); // notify previous screen to refresh
        } else {
          showToast(message: jsonResponse['message'] ?? "Upload failed");
        }
      } else {
        showToast(message: "Upload failed. HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in upload complaint: $e");
      showToast(message: "Something went wrong.");
    }

    setState(() {
      isSending = false;
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

        String fullAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        locationController.text = fullAddress;
      }
    } catch (e) {
      print("Error getting location: $e");
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
          'Add Complaint',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          isSending
              ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
              : IconButton(
                onPressed: uploadComplaint,
                icon: Icon(
                  Icons.done_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              textField(
                titleController,
                Icons.text_fields_rounded,
                'Complaint Title',
              ),
              SizedBox(height: 10),
              textField(
                descriptionController,
                Icons.subject_rounded,
                'Complaint Description',
              ),
              SizedBox(height: 10),
              textField(
                complaintTypeController,
                Icons.assignment_outlined,
                'Type of Complaint',
              ),
              SizedBox(height: 10),
              textField(
                locationController,
                Icons.location_pin,
                'Location',
                isLocationField: true,
              ),
              SizedBox(height: 10),
              textField(
                houseNoController,
                Icons.numbers_rounded,
                'House No. / Flat No.',
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          color: appcolor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          Icons.photo_library_rounded,
                          color: appcolor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Text(
                        "Selected Image:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(
                          _selectedImage!,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textField(
    TextEditingController controller,
    IconData icon,
    String label, {
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
            controller: controller,
            decoration: InputDecoration(
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
}
