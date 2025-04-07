class RequestTlModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String requestType;
  final String imageUrl;
  final String approxWeight;

  final String date;
  final Citizen citizen;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RequestTlModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.requestType,
    required this.imageUrl,
    required this.date,
    required this.approxWeight,
    required this.citizen,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestTlModel.fromJson(Map<String, dynamic> json) {
    return RequestTlModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      requestType: json['requestType'],
      date: json['date'],
      approxWeight: json['approxWeight'] ,
      imageUrl: json['imageUrl'] ?? '',
      citizen: Citizen.fromJson(json['citizenId']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Citizen {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String email;
  final String location;

  Citizen({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.email,
    required this.location,
  });

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      id: json['_id'],
      userName: json['userName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNo: json['phoneNo'],
      email: json['email'],
      location: json['location'],
    );
  }
}
