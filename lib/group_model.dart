class GroupModel {
  final String id;
  final String title;

  GroupModel({required this.id, required this.title});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
    );
  }
}
