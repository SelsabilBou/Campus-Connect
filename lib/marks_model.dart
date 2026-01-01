class MarkRecord {
  final int id;
  final int studentId;
  final int courseId;
  final double mark;
  final String createdAt;
  final String updatedAt;

  const MarkRecord({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.mark,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    final raw = v.toString().replaceAll(',', '.');
    return double.tryParse(raw) ?? fallback;
  }

  factory MarkRecord.fromJson(Map<String, dynamic> json) {
    return MarkRecord(
      id: _toInt(json["id"]),
      studentId: _toInt(json["student_id"]),
      courseId: _toInt(json["course_id"]),
      mark: _toDouble(json["mark"]),
      createdAt: (json["created_at"] ?? "").toString(),
      updatedAt: (json["updated_at"] ?? "").toString(),
    );
  }

  Map<String, String> toPostFields() => {
    "student_id": studentId.toString(),
    "course_id": courseId.toString(),
    "mark": mark.toString(),
  };
}
