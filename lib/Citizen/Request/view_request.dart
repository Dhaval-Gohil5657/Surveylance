import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/Complaint/c_model.dart';
import 'package:surveylance/Citizen/Request/r_model.dart';

class ViewRequest extends StatefulWidget {
  final RequestModel request;

  const ViewRequest({super.key, required this.request});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool isLoading = true;

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
          'Request',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            requestField(Icons.text_fields, widget.request.title, 'Title'),
            requestField(
              Icons.subject_rounded,
              widget.request.description,
              'Description',
            ),
            requestField(
              Icons.assignment_outlined,
              widget.request.requestType,
              'Type of Request',
            ),
            requestField(
              Icons.location_pin,
              widget.request.location,
              'Location',
            ),
            requestField(
              Icons.date_range_rounded,
              DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.parse(widget.request.date)),
              'Date of Collection',
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () {
                    final imageProvider =
                        Image.network(widget.request.imageUrl).image;
                    showImageViewer(context, imageProvider);
                  },
                  child: Image.network(
                    widget.request.imageUrl,
                    fit:
                        BoxFit
                            .contain, // ensures the full image is shown without cropping
                    width: double.infinity,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget requestField(IconData icon, String label, String labelText) {
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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(icon, color: appcolor,size: 20,),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
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
                padding: const EdgeInsets.only(left: 5, right: 5),
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
