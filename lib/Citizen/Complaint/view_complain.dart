import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Citizen/Complaint/c_model.dart';

class ViewComplain extends StatefulWidget {
  final Complaint complaint;
  final String date;

  const ViewComplain({super.key, required this.complaint, required this.date});

  @override
  State<ViewComplain> createState() => _ViewComplainState();
}

class _ViewComplainState extends State<ViewComplain> {
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
          'Complaint',
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
            complainField(
              Icons.text_fields_rounded,
              widget.complaint.title,
              'Title',
            ),
            complainField(
              Icons.subject_rounded,
              widget.complaint.description,
              'Description',
            ),
            complainField(
              Icons.assignment_outlined,
              widget.complaint.complaintType,
              'Type of Complaint',
            ),
            complainField(
              Icons.location_pin,
              widget.complaint.location,
              'Location',
            ),
            complainField(
              Icons.date_range_rounded,
              widget.date,
              'Date of Complaint',
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () {
                    final imageProvider =
                        Image.network(widget.complaint.imageUrl).image;
                    showImageViewer(context, imageProvider);
                  },
                  child: Image.network(
                    widget.complaint.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 300,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.white,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: appcolor,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.white,
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

  Widget complainField(IconData icon, String label, String labelText) {
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
                      Icon(icon, color: appcolor, size: 20),
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
