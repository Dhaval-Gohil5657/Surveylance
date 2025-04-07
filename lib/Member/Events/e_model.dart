class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String date;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
    );
  }}