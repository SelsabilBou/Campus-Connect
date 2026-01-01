import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'teacher_service.dart';
import 'course_model.dart';
import 'course_students_screen.dart';
import 'course_files_screen.dart';
import 'teacher_dashboard.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final service = TeacherService.instance;

  bool _loading = false;
  List<CourseModel> _courses = [];

  // ---- SEARCH (Phase 4) ----
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = "";

  List<CourseModel> get _filteredCourses {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _courses;

    return _courses.where((c) {
      final title = c.title.toLowerCase();
      final idStr = c.id.toString().toLowerCase(); // FIX: id can be int/string
      return title.contains(q) || idStr.contains(q);
    }).toList();
  }

  void _showSnack(String msg) {
    TeacherDashboard.messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = v);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final res = await service.fetchCourses();
      if (!mounted) return;
      setState(() => _courses = res);
    } catch (e) {
      _showSnack("Load courses failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCourses;

    return Column(
      children: [
        if (_loading) const LinearProgressIndicator(minHeight: 3),

        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search courses (name/id)...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.trim().isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = "");
                },
                icon: const Icon(Icons.close),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F5FF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
              ),
            ),
          ),
        ),

        Expanded(
          child: list.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("No courses"),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading ? null : _loadCourses,
                  child: const Text("Refresh"),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadCourses,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = list[index];
                final courseId = int.tryParse(c.id.toString()) ?? 0;
                return _CourseCard(
                  courseId: courseId,
                  name: c.title,
                  group: "—",
                  schedule: "—",
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatefulWidget {
  final int courseId;
  final String name;
  final String group;
  final String schedule;

  const _CourseCard({
    required this.courseId,
    required this.name,
    required this.group,
    required this.schedule,
  });

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _uploading = false;

  void _showSnack(String msg) {
    TeacherDashboard.messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _pickAndUpload() async {
    if (_uploading) return;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) {
      _showSnack("Pick file failed: path is null");
      return;
    }

    setState(() => _uploading = true);

    try {
      final uploaded = await TeacherService.instance.uploadCourseFile(
        courseId: widget.courseId,
        file: File(path),
      );

      _showSnack("Uploaded: ${uploaded.name}");
    } catch (e) {
      // backend message مثال: "File upload failed" / "Forbidden..." / "Unauthorized"
      _showSnack("Upload failed: $e");
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6A3DE8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Course Name: ${widget.name}", style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text("Group: ${widget.group}", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text("Weekly Schedule: ${widget.schedule}", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),

          if (_uploading) const LinearProgressIndicator(minHeight: 3),
          if (_uploading) const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _uploading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseStudentsScreen(
                          courseId: widget.courseId,
                          courseName: widget.name,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: purple),
                    foregroundColor: purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("View Students"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _uploading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseFilesScreen(
                          courseId: widget.courseId,
                          courseName: widget.name,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: purple),
                    foregroundColor: purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("View Files"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _uploading ? null : _pickAndUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(_uploading ? "Uploading..." : "Upload"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
