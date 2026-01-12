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

  static int _toInt(dynamic v, {int fallback = 0}) {//convertir to int
    if (v == null) return fallback;
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory CourseFile.fromJson(Map<String, dynamic> json) {//construire une instance dr coursefile
    return CourseFile(
      id: _toInt(json["id"]),
      courseId: _toInt(json["course_id"]),
      name: (json["name"] ?? "").toString(),
      tag: (json["tag"] ?? "").toString(),
      path: (json["path"] ?? "").toString(),
      createdAt: (json["created_at"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {//transfer lobject dart to json
    "id": id,
    "course_id": courseId,
    "name": name,
    "tag": tag,
    "path": path,
    "created_at": createdAt,
  };

  Map<String, String> toPostFields() => {//preparer lobject pour envoyer dans HTTP
    "id": id.toString(),
    "course_id": courseId.toString(),
    "name": name,
    "tag": tag,
    "path": path,
    "created_at": createdAt,
  };
}
