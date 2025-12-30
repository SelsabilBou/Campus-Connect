import 'file_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentService {
  StudentService._();
  static final StudentService instance = StudentService._();

  // Phase 2: dummy logic – later will call PHP

  Future<List<Map<String, String>>> viewSchedule(String groupId) async {
    final url = Uri.parse('http://10.0.2.2/compuse_app/view_schedule.php');

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
        .map<Map<String, String>>((e) => {
      'day': e['day'].toString(),
      'course': e['course'].toString(),
      'time': e['time'].toString(),
    })
        .toList();
  }


  Future<List<Map<String, dynamic>>> viewMarks(int studentId) async {
    final url = Uri.parse('http://10.0.2.2/compuse_app/view_marks.php');

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
  Future<List<FileModel>> viewFiles(String groupOrCourse) async {
    final url = Uri.parse('http://10.0.2.2/compuse_app/view_files.php');

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


}
