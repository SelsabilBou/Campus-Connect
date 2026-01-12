import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'attendance_model.dart';
import 'course_file_model.dart';
import 'marks_model.dart';
import 'course_model.dart';
import 'student_model.dart';

class TeacherService {
  TeacherService._();
  static final TeacherService instance = TeacherService._();

  static const baseUrl = "http://10.0.2.2/compuse_app";
  Duration get _timeout => const Duration(seconds: 15);

  Map<String, dynamic> _decodeJsonObject(http.Response res) {
    try {
      final body = utf8.decode(res.bodyBytes);
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception("Bad JSON (not an object): $body");
    } on FormatException {
      throw Exception("Bad JSON response: ${res.body}");
    }
  }

  Future<Map<String, String>> _teacherAuthBody() async {
    final teacherId = await AuthService.getTeacherId();
    final apiKey = await AuthService.getTeacherApiKey();
    if (teacherId == null || apiKey == null || apiKey.isEmpty) {
      throw Exception("Not logged in as teacher");
    }
    return {
      "teacher_id": teacherId.toString(),
      "api_key": apiKey,
    };
  }

  // ✅ CORRECTION: Utiliser teacher_courses_read.php avec authentification
  Future<List<CourseModel>> fetchCourses() async {
    final uri = Uri.parse("$baseUrl/teacher_courses_read.php");
    final auth = await _teacherAuthBody();

    // ✅ Envoyer en POST avec les credentials
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(auth),
    ).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final decoded = _decodeJsonObject(res);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Fetch courses failed");
    }

    // ✅ Chercher 'courses' au lieu de 'data'
    final list = (decoded["courses"] ?? []) as List;
    return list.map((e) => CourseModel.fromJson(e)).toList();
  }

  // ---------------- STUDENTS (Pagination ready) ----------------
  Future<List<StudentModel>> fetchStudentsByCourse(
      int courseId, {
        int page = 1,
        int limit = 50,
      }) async {
    final uri = Uri.parse(
      "$baseUrl/students_read.php?course_id=$courseId&page=$page&limit=$limit",
    );

    final res = await http
        .get(uri, headers: {"Accept": "application/json"})
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final decoded = _decodeJsonObject(res);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Fetch students failed");
    }

    final list = (decoded["data"] ?? []) as List;
    return list.map((e) => StudentModel.fromJson(e)).toList();
  }

  // ---------------- FILES ----------------
  Future<CourseFile> uploadCourseFile({
    required int courseId,
    required File file,
    String tag = "Timetable",
  }) async {
    final uri = Uri.parse("$baseUrl/upload_file.php");
    final auth = await _teacherAuthBody();

    final req = http.MultipartRequest("POST", uri)
      ..fields.addAll(auth)
      ..fields["course_id"] = courseId.toString()
      ..fields["tag"] = tag
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final data = _decodeJsonObject(res);
    if (data["success"] != true) {
      throw Exception(data["message"]?.toString() ?? "File upload failed");
    }

    return CourseFile(
      id: 0,
      courseId: int.tryParse((data["course_id"] ?? courseId).toString()) ?? courseId,
      name: data["name"]?.toString() ?? "",
      tag: data["tag"]?.toString() ?? tag,
      path: data["path"]?.toString() ?? "",
      createdAt: (data["created_at"] ?? "").toString(),
    );
  }

  Future<List<CourseFile>> getCourseFiles(int courseId) async {
    final uri = Uri.parse("$baseUrl/files_read.php?course_id=$courseId");
    final res = await http
        .get(uri, headers: {"Accept": "application/json"})
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final decoded = _decodeJsonObject(res);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Fetch files failed");
    }

    final list = (decoded["data"] ?? []) as List;
    return list.map((e) => CourseFile.fromJson(e)).toList();
  }

  Future<void> deleteFile(int fileId) async {
    final uri = Uri.parse("$baseUrl/file_delete.php");
    final auth = await _teacherAuthBody();

    final res = await http.post(uri, body: {
      ...auth,
      "id": fileId.toString(),
    }).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final decoded = _decodeJsonObject(res);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Delete failed");
    }
  }

  // ---------------- MARKS ----------------
  Future<void> updateMark({
    required int studentId,
    required int courseId,
    required double mark,
  }) async {
    final uri = Uri.parse("$baseUrl/marks_upsert.php");
    final auth = await _teacherAuthBody();

    final res = await http.post(uri, body: {
      ...auth,
      "student_id": studentId.toString(),
      "course_id": courseId.toString(),
      "mark": mark.toString(),
    }).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final data = _decodeJsonObject(res);
    if (data["returnerror"] == true) {
      throw Exception(data["returnmessage"]?.toString() ?? "Mark save failed");
    }
  }

  Future<List<MarkRecord>> fetchMarksByCourse(int courseId) async {
    final uri = Uri.parse("$baseUrl/marks_get.php?course_id=$courseId");
    final res = await http
        .get(uri, headers: {"Accept": "application/json"})
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final data = _decodeJsonObject(res);
    if (data["returnerror"] == true) {
      throw Exception(data["returnmessage"]?.toString() ?? "Fetch marks failed");
    }

    final list = (data["data"] ?? []) as List;
    return list.map((e) => MarkRecord.fromJson(e)).toList();
  }

  // ---------------- ATTENDANCE ----------------
  Future<void> markAttendance({
    required int studentId,
    required int courseId,
    required int week,
    required bool present,
  }) async {
    final uri = Uri.parse("$baseUrl/attendance_upsert.php");
    final auth = await _teacherAuthBody();

    final res = await http.post(uri, body: {
      ...auth,
      "student_id": studentId.toString(),
      "course_id": courseId.toString(),
      "week": week.toString(),
      "present": present ? "1" : "0",
    }).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final decoded = _decodeJsonObject(res);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Attendance save failed");
    }
  }

  Future<AttendanceRecord?> getAttendance({
    required int studentId,
    required int courseId,
    required int week,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/attendance_get.php?student_id=$studentId&course_id=$courseId&week=$week",
    );

    final res = await http
        .get(uri, headers: {"Accept": "application/json"})
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}");
    }

    final decoded = _decodeJsonObject(res);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Fetch attendance failed");
    }

    final row = decoded["data"];
    if (row == null) return null;

    return AttendanceRecord.fromJson(row as Map<String, dynamic>);
  }
}
