// admin_service.dart
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

  final String baseUrl = 'http://10.0.2.2/compuse_app';

  Duration get _timeout => const Duration(seconds: 12);

  // --- URLs helpers ---

  Uri _u(String path) => Uri.parse('$baseUrl/$path');

  // PUBLIC: utilisé par StudentAllScreen
  Uri buildUri(String path, {Map<String, String>? query}) {
    return Uri.parse('$baseUrl/$path').replace(queryParameters: query);
  }

  // --- JSON helpers ---

  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = json.decode(body);

    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (decoded is Map && decoded['data'] is List) {
      final List data = decoded['data'];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = json.decode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'success': false, 'message': 'Invalid JSON'};
  }

  ApiResult _resultFromResponse(http.Response res) {
    if (res.statusCode != 200) {
      return ApiResult(success: false, message: 'HTTP ${res.statusCode}');
    }
    final data = _decodeMap(res.body);
    return ApiResult(
      success: data['success'] == true,
      message:
      (data['message'] ?? (data['success'] == true ? 'OK' : 'Error'))
          .toString(),
    );
  }

  // PUBLIC: utilisés par StudentAllScreen
  Future<http.Response> getRaw(Uri uri) {
    return http.get(uri).timeout(_timeout);
  }

  List<Map<String, dynamic>> decodeList(String body) {
    return _decodeList(body);
  }

  // ---------- Students pending ----------

  Future<List<Map<String, dynamic>>> fetchPendingStudents({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final uri = _u('students_pending.php').replace(queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      });

      final res = await http.get(uri).timeout(_timeout);
      print('PENDING STATUS=${res.statusCode}');
      print('PENDING BODY=${res.body}');

      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (e) {
      print('PENDING ERROR=$e');
      return [];
    }
  }

  Future<ApiResult> approveStudent(int id) async {
    try {
      final res = await http
          .post(
        _u('student_approve.php'),
        body: {'id': id.toString()},
      )
          .timeout(_timeout);
      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<ApiResult> rejectStudent(int id) async {
    try {
      final res = await http
          .post(
        _u('student_reject.php'),
        body: {'id': id.toString()},
      )
          .timeout(_timeout);
      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<ApiResult> assignCourseToStudent(
      int studentId, String courseId) async {
    try {
      final res = await http
          .post(
        _u('student_assign_course.php'),
        body: {
          'studentId': studentId.toString(),
          'courseId': courseId,
        },
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  // ---------- assign group to student ----------

  Future<ApiResult> assignGroupToStudent(
      int studentId, String groupId) async {
    try {
      final res = await http
          .post(
        _u('student_assign_group.php'),
        body: {
          'studentId': studentId.toString(),
          'groupId': groupId,
        },
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  // ---------- Teachers / groups / courses ----------

  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      final res = await http.get(_u('teachers_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  Future<ApiResult> assignGroupToTeacher(
      int teacherId, String groupId) async {
    try {
      final res = await http
          .post(
        _u('teacher_assign_group.php'),
        body: {
          'teacherId': teacherId.toString(),
          'groupId': groupId,
        },
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<ApiResult> assignCourseToTeacher(
      int teacherId, String courseId) async {
    try {
      final res = await http
          .post(
        _u('teacher_assign_course.php'),
        body: {
          'teacherId': teacherId.toString(),
          'courseId': courseId,
        },
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<ApiResult> assignCourseToGroup(
      String groupId, String courseId) async {
    try {
      final res = await http
          .post(
        _u('group_assign_course.php'),
        body: {
          'groupId': groupId,
          'courseId': courseId,
        },
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<List<GroupModel>> fetchGroups() async {
    try {
      final res = await http.get(_u('groups_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = _decodeList(res.body);
      return list.map((e) => GroupModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroupsRaw() async {
    try {
      final res = await http.get(_u('groups_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  // ✅ AJOUTÉ: méthode manquante pour teacher_management.dart
  Future<List<Map<String, dynamic>>> fetchAvailableGroups() async {
    return await fetchGroupsRaw();
  }

  Future<List<CourseModel>> fetchCourses() async {
    try {
      final res = await http.get(_u('courses_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = _decodeList(res.body);
      return list.map((e) => CourseModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCoursesRaw() async {
    try {
      final res = await http.get(_u('courses_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  // ---------- Files ----------

  Future<ApiResult> uploadFile({
    required File file,
    required String tag,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _u('upload_file.php'));
      request.fields['tag'] = tag;
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamed = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFiles() async {
    try {
      final res = await http.get(_u('files_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  Future<ApiResult> deleteStudent(int id) async {
    try {
      final res = await http
          .post(
        _u('student_delete.php'),
        body: {'id': id.toString()},
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  Future<ApiResult> deleteFile(int id) async {
    try {
      final res = await http
          .post(
        _u('file_delete.php'),
        body: {'id': id.toString()},
      )
          .timeout(_timeout);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }
}
