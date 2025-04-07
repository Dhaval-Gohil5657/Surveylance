class RequestModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String date;
  final String approxWeight;
  final String requestType;
  final String imageUrl;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.approxWeight,
    required this.requestType,
    required this.imageUrl,
    required this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      date: json['date'],
      approxWeight: json['approxWeight'],
      requestType: json['requestType'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
