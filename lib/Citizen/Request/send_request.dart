import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

class SendRequest extends StatefulWidget {
  const SendRequest({super.key});

  @override
  State<SendRequest> createState() => _SendRequestState();
}

class _SendRequestState extends State<SendRequest> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController requestTypeController = TextEditingController();
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

  Future<void> sendRequest() async {
     if (titleController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          locationController.text.isEmpty ||
          weightController.text.isEmpty ||
          dateController.text.isEmpty ||
          requestTypeController.text.isEmpty) {
        showToast(message: "Please fill all the details");

      
        if (_selectedImage == null) {
          showToast(message: "Please select image");
        }
      }

      setState(() {
        isSending = true;
      });
    try {
      String? authToken = await storage.read(key: "auth_token");

      String uploadUrl = "$baseurl/surv/uploadRequest";
      final uri = Uri.parse(uploadUrl);

      var request = http.MultipartRequest('POST', uri);
     

      request.headers['Authorization'] = 'Bearer $authToken';
      // print("Sending Headers: ${request.headers}");

      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['location'] = locationController.text.trim();
      request.fields['date'] = dateController.text.trim();
      request.fields['approxWeight'] = weightController.text.trim();
      request.fields['requestType'] = requestTypeController.text.trim();

        request.files.add(
          await http.MultipartFile.fromPath(
            'requestFile',
            _selectedImage!.path,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Response received: $responseBody");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          String requestId = jsonResponse['data']['request']['_id'];
          await storage.write(key: "last_uploaded_Id", value: requestId);
          print("request send successfully, ID: $requestId");

          showToast(message: "Request send successfully");
          Navigator.pop(context, true);
          return;
        } else {
          //  ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text("${jsonResponse['message']}")));
          print("Failed to upload Request: ${jsonResponse['message']}");
        }
      } else {
        print("Failed to upload Request: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in upload Request: $e");
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
          'Send Request',
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
                onPressed: sendRequest,
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
                'Request Title',
              ),
              SizedBox(height: 10),
              textField(
                descriptionController,
                Icons.subject_rounded,
                'Request Description',
              ),
              SizedBox(height: 10),
              textField(
                requestTypeController,
                Icons.live_help_outlined,
                'Type of Request',
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
                weightController,
                Icons.av_timer_rounded,
                'Approximate weight(in Kg)',
              ),
              SizedBox(height: 10),
              dateField(
                dateController,
                Icons.calendar_month_outlined,
                DateTime.now(),
                'Date for collection',
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
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          height: 180,
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

  Widget dateField(
    TextEditingController controller,
    IconData icon,
    // Function setDialogState,
    DateTime? selectedDate,
    String label,
  ) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.white,
      child: TextField(
        style: TextStyle(fontSize: 15),
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
          // suffixIcon: Icon(Icons.calendar_month, color: appcolor),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year, 12, 31),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDate = pickedDate;
              controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
      ),
    );
  }
}
