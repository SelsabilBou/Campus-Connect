import 'dart:convert';
import 'package:http/http.dart' as http;

import 'file_model.dart';

class StudentService {
  StudentService._();
  static final StudentService instance = StudentService._();

  static const String _baseUrl = 'http://10.0.2.2/compuse_app';

  // ---------- Schedule ----------

  Future<List<Map<String, String>>> viewSchedule(String groupId) async {
    final url = Uri.parse('$_baseUrl/view_schedule.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'group_name': groupId}),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to load schedule');
    }

    final List list = data['schedule'] ?? [];

    return list
        .map<Map<String, String>>(
          (e) => {
        'day': e['day'].toString(),
        'course': e['course'].toString(),
        'time': e['time'].toString(),
      },
    )
        .toList();
  }

  // ---------- Marks ----------

  Future<List<Map<String, dynamic>>> viewMarks(int studentId) async {
    final url = Uri.parse('$_baseUrl/view_marks.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId}),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to load marks');
    }

    final List list = data['marks'] ?? [];
    return list
        .map<Map<String, dynamic>>(
          (e) => {
        'course': e['course'],
        'cc': double.tryParse(e['cc'].toString()) ?? 0,
        'exam': double.tryParse(e['exam'].toString()) ?? 0,
      },
    )
        .toList();
  }

  // ---------- Files (pagination) ----------

  /// Ancienne méthode simple (sans pagination) — tu peux la garder si tu veux
  /// pour tests, ou la supprimer une fois la pagination utilisée partout.
  Future<List<FileModel>> viewFiles(String groupOrCourse) async {
    final url = Uri.parse('$_baseUrl/view_files.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'group_or_course': groupOrCourse}),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to load files');
    }

    final List list = data['files'] ?? [];

    return list
        .map<FileModel>((e) => FileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Nouveau: récupération paginée des fichiers pour un group
  Future<PaginatedFiles> viewFilesPaged(
      String group, int page, int limit) async {
    final uri = Uri.parse('$_baseUrl/view_files.php').replace(
      queryParameters: {
        'group': group,
        'page': '$page',
        'limit': '$limit',
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['success'] != true) {
      throw Exception(map['error'] ?? 'Failed to load files');
    }

    return PaginatedFiles.fromJson(map);
  }
}

/// Résultat paginé pour les fichiers
class PaginatedFiles {
  final List<FileModel> files;
  final bool hasMore;

  PaginatedFiles({required this.files, required this.hasMore});

  factory PaginatedFiles.fromJson(Map<String, dynamic> json) {
    final list = (json['files'] as List? ?? []);
    return PaginatedFiles(
      files: list
          .map((e) => FileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] == true,
    );
  }
}
