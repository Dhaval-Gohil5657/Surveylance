import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Widgets/toast.dart';
import 'package:surveylance/url.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  DateTime? selectedDate;
  bool isSending = false;

  Future<void> _addEvent() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please complete all fields')));
      return;
    }

    setState(() {
      isSending = true;
    });

    final url = Uri.parse('$baseurl/surv/createEvent');

    try {
      String? authToken = await storage.read(key: "auth_token");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': titleController.text.trim(),
          'description': descController.text.trim(),
          'location': locationController.text.trim(),
          'date': selectedDate!.toIso8601String().split('T')[0],
        }),
      );

      final responseData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 201 && responseData['success']) {
        showToast(message: 'Event created successfully!');
        Navigator.pop(context,true);
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to create event'),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong')));
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
                onPressed: _addEvent,
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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              textField(
                titleController,
                Icons.text_fields_rounded,
                'Event Title',
              ),
              SizedBox(height: 8),
              textField(descController, Icons.subject_rounded, 'Discription'),
              SizedBox(height: 8),
              textField(
                locationController,
                Icons.location_pin,
                'Location',
                isLocationField: true,
              ),
              SizedBox(height: 8),
              dateField(dateController, Icons.date_range_rounded, 'Event Date'),
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
              selectedDate = pickedDate; // ✅ Now updates state variable
              controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
      ),
    );
  }
}
