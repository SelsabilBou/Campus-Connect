import 'package:flutter/material.dart';
import 'teacher_service.dart';
import 'course_file_model.dart';

class CourseFilesScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const CourseFilesScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseFilesScreen> createState() => _CourseFilesScreenState();
}

class _CourseFilesScreenState extends State<CourseFilesScreen> {
  final service = TeacherService.instance;

  bool _loading = false;
  List<CourseFile> _files = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _files = await service.getCourseFiles(widget.courseId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Load files failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.courseName} Files")),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: _files.isEmpty
                ? const Center(child: Text("No files"))
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _files.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final f = _files[i];
                return ListTile(
                  title: Text(f.name),
                  subtitle: Text(
                    f.tag.isEmpty ? f.path : "${f.tag} • ${f.path}",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
