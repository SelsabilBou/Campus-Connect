// hada howa le fichier li yahki me3a backend
import 'dart:convert';
import 'dart:io'; // netal3ou bih les fichier
import 'package:http/http.dart' as http; // lel get w l post

import 'group_model.dart';
import 'course_model.dart';

class ApiResult {
  // classe représenter la réponse d'une api
  final bool success;
  final String message;
  ApiResult({required this.success, required this.message});
}

class AdminService {
  // classe privé bah ne9drou nedirou instance wahda men adminservice
  AdminService._();
  static final AdminService instance = AdminService._();

  final String baseUrl = 'http://10.0.2.2/compuse_app'; // api php

  // mewe9t li nemedouh l les requete http bah yedarou ida fat
  Duration get _timeout => const Duration(seconds: 12);

  // construire les urls
  Uri _u(String path) => Uri.parse('$baseUrl/$path');

  // tered l json li jay men back l list_map_dart
  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = json.decode(body);

    if (decoded is List) {
      // si le backend renvoie list neredou kol object map
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (decoded is Map && decoded['data'] is List) {
      // ida yered json list ta3 key w data yered kol wahda map
      final List data = decoded['data'];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // ida mach les deux forme yered list vide
    return [];
  }

  // tered ay json yeji men backend teredou map
  Map<String, dynamic> _decodeMap(String body) {
    final decoded = json.decode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'success': false, 'message': 'Invalid JSON'};
  }

  // ki tekon la reponse !200 yekherej error
  ApiResult _resultFromResponse(http.Response res) {
    if (res.statusCode != 200) {
      return ApiResult(success: false, message: 'HTTP ${res.statusCode}');
    }
    // decode le body json en map
    final data = _decodeMap(res.body);
    return ApiResult(
      success: data['success'] == true,
      message:
      (data['message'] ?? (data['success'] == true ? 'OK' : 'Error'))
          .toString(),
    );
  }

  // ---------- Students pending ----------

  // charger les etud en attente
  Future<List<Map<String, dynamic>>> fetchPendingStudents({
    int limit = 20, // le max li te9der tejib
    int offset = 0, // menin tebda f la list
  }) async {
    try {
      final uri = _u('students_pending.php').replace(queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      }); // yewejed l url w yezid fih limit w offset bah yedir pagination

      // lance la requete
      final res = await http.get(uri).timeout(_timeout);
      print('PENDING STATUS=${res.statusCode}');
      print('PENDING BODY=${res.body}');

      // ida le code mach 200 yerd list vide
      if (res.statusCode != 200) return [];
      // yerd le body json en list<map>
      return _decodeList(res.body);
    } catch (e) {
      // ida setar error
      print('PENDING ERROR=$e');
      return [];
    }
  }

  // envoie une requete post bah dir approve
  Future<ApiResult> approveStudent(int id) async {
    try {
      final res = await http
          .post(
        _u('student_approve.php'),
        body: {'id': id.toString()},
      )
          .timeout(_timeout);
      // si réussite en transfer la réponse en ApiResult
      return _resultFromResponse(res);
    } catch (_) {
      // cas d'erreur
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  // dir reject
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

  // assigner un cours à un student
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

      // la reponse yerdha ApiResult
      return _resultFromResponse(res);
    } catch (_) {
      // traitement d'error
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

  // yeb3et get l php bah yejib la liste ta3 teachers
  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      final res = await http.get(_u('teachers_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      // yerdha list<map>
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  // yeb3et post bah yedir assign group l teacher
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

      // Transforme la réponse en ApiResult.
      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  // NEW: assign course to teacher
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

  // NEW: assign course to group
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

  // yebe3et get bah yejib la list des grp
  Future<List<GroupModel>> fetchGroups() async {
    try {
      final res = await http.get(_u('groups_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = _decodeList(res.body);
      // convertir en objets GroupModel
      return list.map((e) => GroupModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // tejib les group bela ma teredhom GroupModel
  Future<List<Map<String, dynamic>>> fetchGroupsRaw() async {
    try {
      final res = await http.get(_u('groups_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  // envoie un get bah tejib l courses
  Future<List<CourseModel>> fetchCourses() async {
    try {
      final res = await http.get(_u('courses_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = _decodeList(res.body);
      // convertir en CourseModel
      return list.map((e) => CourseModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // tejob l courses bela ma teredhom CourseModel
  Future<List<Map<String, dynamic>>> fetchCoursesRaw() async {
    try {
      final res = await http.get(_u('courses_read.php')).timeout(_timeout);
      if (res.statusCode != 200) return [];
      // yerdhom list
      return _decodeList(res.body);
    } catch (_) {
      return [];
    }
  }

  // ---------- Files ----------

  // upload un fichier au serveur
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

      // yejib un reponse de type StreamedResponse
      final streamed = await request.send().timeout(_timeout);
      // tered StreamedResponse l http response
      final res = await http.Response.fromStream(streamed);

      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  // tebe3t get bah tejib la list des fichier
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

      // même logique que approve/reject
      return _resultFromResponse(res);
    } catch (_) {
      return ApiResult(success: false, message: 'Network/timeout');
    }
  }

  // post pour supprimer les fichier
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
