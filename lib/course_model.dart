class CourseModel {
  final String id;
  final String title;

  CourseModel({required this.id, required this.title});

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
    );
  }
}
