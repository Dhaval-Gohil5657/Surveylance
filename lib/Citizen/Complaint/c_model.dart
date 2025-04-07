class Complaint {
  final String id;
  final String title;
  final String description;
  final String location;
  final String houseNo;
  final String complaintType;
  final String imageUrl;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.houseNo,
    required this.complaintType,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      houseNo: json['houseNo'] ?? '',
      complaintType: json['complaintType'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
