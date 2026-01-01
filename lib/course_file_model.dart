class CourseFile {
  final int id;
  final int courseId;
  final String name;
  final String tag;
  final String path;
  final String createdAt;

  const CourseFile({
    required this.id,
    required this.courseId,
    required this.name,
    required this.tag,
    required this.path,
    required this.createdAt,
  });

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory CourseFile.fromJson(Map<String, dynamic> json) {
    return CourseFile(
      id: _toInt(json["id"]),
      courseId: _toInt(json["course_id"]),
      name: (json["name"] ?? "").toString(),
      tag: (json["tag"] ?? "").toString(),
      path: (json["path"] ?? "").toString(),
      createdAt: (json["created_at"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "course_id": courseId,
    "name": name,
    "tag": tag,
    "path": path,
    "created_at": createdAt,
  };

  // مفيد لـ http.post (body غالبا لازم تكون String,String)
  Map<String, String> toPostFields() => {
    "id": id.toString(),
    "course_id": courseId.toString(),
    "name": name,
    "tag": tag,
    "path": path,
    "created_at": createdAt,
  };
}
