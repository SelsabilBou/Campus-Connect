import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'group_model.dart';
import 'course_model.dart';

class ApiResult {
  final bool success;
  final String message;
  ApiResult({required this.success, required this.message});
}

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  // Android Emulator -> PC localhost
  final String baseUrl = "http://10.0.2.2/compuse_app";

  Duration get _timeout => const Duration(seconds: 12);

  // ---------- Helpers ----------
  Uri _u(String path) => Uri.parse("$baseUrl/$path");

  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = json.decode(body);

    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (decoded is Map && decoded["data"] is List) {
      final List data = decoded["data"];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = json.decode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {"success": false, "message": "Invalid JSON"};
  }

  ApiResult _resultFromResponse(http.Response res) {
    if (res.statusCode != 200) {
      return ApiResult(success: false, message: "HTTP ${res.statusCode}");
    }
    final data = _decodeMap(res.body);
    return ApiResult(
      success: data["success"] == true,
      message: (data["message"] ?? (data["success"] == true ? "OK" : "Error")).toString(),
    );
  }

  // ---------- Debug (اختياري) ----------
  Future<void> ping() async {
    final url = _u("courses_read.php");
    final res = await http.get(url).timeout(_timeout);
    // ignore: avoid_print
    print("URL=$url");
    // ignore: avoid_print
    print("STATUS=${res.statusCode}");
    // ignore: avoid_print
    print("BODY=${res.body}");
  }

  // ---------- Students ----------
  // Phase 5: Pagination ready
  Future<List<Map<String, dynamic>>> fetchPendingStudents({int limit = 20, int offset = 0}) async {
    try {
      final uri = _u("students_pending.php").replace(queryParameters: {
        "limit": limit.toString(),
        "offset": offset.toString(),
      });

      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  Future<ApiResult> approveStudent(int id) async {
    try {
      final res = await http
          .post(_u("student_approve.php"), body: {"id": id.toString()})
          .timeout(_timeout);
      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: "Network/timeout");
    }
  }

  Future<ApiResult> rejectStudent(int id) async {
    try {
      final res = await http
          .post(_u("student_reject.php"), body: {"id": id.toString()})
          .timeout(_timeout);
      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: "Network/timeout");
    }
  }

  Future<ApiResult> assignCourseToStudent(int studentId, String courseId) async {
    try {
      final res = await http.post(
        _u("student_assign_course.php"),
        body: {"studentId": studentId.toString(), "courseId": courseId},
      ).timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: "Network/timeout");
    }
  }

  // ---------- Teachers ----------
  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      final res = await http.get(_u("teachers_read.php")).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  Future<ApiResult> assignGroupToTeacher(int teacherId, String groupId) async {
    try {
      final res = await http.post(
        _u("teacher_assign_group.php"),
        body: {"teacherId": teacherId.toString(), "groupId": groupId},
      ).timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: "Network/timeout");
    }
  }

  // ---------- Groups & Courses ----------
  Future<List<GroupModel>> fetchGroups() async {
    try {
      final res = await http.get(_u("groups_read.php")).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = _decodeList(res.body);
      return list.map((e) => GroupModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroupsRaw() async {
    try {
      final res = await http.get(_u("groups_read.php")).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  Future<List<CourseModel>> fetchCourses() async {
    try {
      final res = await http.get(_u("courses_read.php")).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = _decodeList(res.body);
      return list.map((e) => CourseModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCoursesRaw() async {
    try {
      final res = await http.get(_u("courses_read.php")).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  // ---------- Files ----------
  Future<ApiResult> uploadFile({required File file, required String tag}) async {
    try {
      final request = http.MultipartRequest("POST", _u("upload_file.php"));
      request.fields["tag"] = tag;
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final streamed = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed); // lire le body [web:300]

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: "Network/timeout");
    }
  }

  Future<List<Map<String, dynamic>>> fetchFiles() async {
    try {
      final res = await http.get(_u("files_read.php")).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  Future<ApiResult> deleteFile(int id) async {
    try {
      final res = await http
          .post(_u("file_delete.php"), body: {"id": id.toString()})
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: "Network/timeout");
    }
  }
}
