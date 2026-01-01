class StudentModel {
  final int id;
  final String name;

  const StudentModel({required this.id, required this.name});

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: _toInt(json["id"]),
    name: (json["name"] ?? "").toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
