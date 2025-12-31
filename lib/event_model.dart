class EventModel {
  final int id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String groupName;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.groupName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: int.parse(json['id'].toString()),
      title: json['title'].toString(),
      description: (json['description'] ?? '').toString(),
      eventDate: DateTime.parse(json['event_date'].toString()),
      groupName: json['group_name'].toString(),
    );
  }
}
