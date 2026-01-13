import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';  // assure-toi que le chemin est bon

class TeacherFileService {
  // Mets ici la même baseUrl que dans AuthService,
  // ou importe AuthService.baseUrl si tu préfères.
  static const String baseUrl = 'http://10.0.2.2/compuse_app';

  // Upload d’un fichier pour un cours
  static Future<bool> uploadCourseFile({
    required int courseId,
    required String filePath,
    String tag = 'TeacherFile',
  }) async {
    final user = await AuthService.getLoggedInUser();
    if (user == null || user.role.toLowerCase() != 'teacher') {
      throw Exception('Not logged in as teacher');
    }

    final uri = Uri.parse('$baseUrl/teacher_upload_file.php');

    final request = http.MultipartRequest('POST', uri)
      ..fields['course_id'] = courseId.toString()
      ..fields['teacher_id'] = user.id.toString()
      ..fields['tag'] = tag
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(body);
      if (json['success'] == true) return true;
      throw Exception(json['error'] ?? 'Upload failed');
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // Récupérer les fichiers du teacher pour un cours
  static Future<List<dynamic>> getTeacherFiles(int courseId) async {
    final user = await AuthService.getLoggedInUser();
    if (user == null || user.role.toLowerCase() != 'teacher') {
      throw Exception('Not logged in as teacher');
    }

    final uri = Uri.parse(
      '$baseUrl/teacher_list_files.php?course_id=$courseId&teacher_id=${user.id}',
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final json = jsonDecode(resp.body);
    if (json['success'] == true) {
      return (json['files'] as List<dynamic>);
    } else {
      throw Exception(json['error'] ?? 'Failed to load files');
    }
  }
}
