class AttendanceRecord {
  final int studentId;
  final int week;
  final bool present;

  const AttendanceRecord({
    required this.studentId,
    required this.week,
    required this.present,
  });

  AttendanceRecord copyWith({bool? present}) {
    return AttendanceRecord(
      studentId: studentId,
      week: week,
      present: present ?? this.present,
    );
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: int.parse((json["student_id"] ?? 0).toString()),
      week: int.parse((json["week"] ?? 0).toString()),
      present: (json["present"].toString() == "1" || json["present"] == true),
    );
  }

  Map<String, String> toPostFields() => {
    "student_id": studentId.toString(),
    "week": week.toString(),
    "present": present ? "1" : "0",
  };
}
