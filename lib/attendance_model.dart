class AttendanceRecord {//classe ta3 la presence
  final int studentId;
  final int week;
  final bool present;

  const AttendanceRecord({
    required this.studentId,
    required this.week,
    required this.present,
  });

  AttendanceRecord copyWith({bool? present}) {//une instance
    return AttendanceRecord(
      studentId: studentId,
      week: week,
      present: present ?? this.present,//ida medinalou present jedida yehetha alse yekheli legdima
    );
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {//nejibou jason on la transforme en object dart
    return AttendanceRecord(
      studentId: int.parse((json["student_id"] ?? 0).toString()),//recupérer id en json et convertir en int
      week: int.parse((json["week"] ?? 0).toString()),
      present: (json["present"].toString() == "1" || json["present"] == true),//convertir json en booléen dart
    );
  }

  Map<String, String> toPostFields() => {//preparer les donne pour un POST HTTP
    "student_id": studentId.toString(),
    "week": week.toString(),
    "present": present ? "1" : "0",
  };
}
