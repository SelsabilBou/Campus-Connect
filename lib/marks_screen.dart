import 'package:flutter/material.dart';
import 'teacher_service.dart';
import 'student_model.dart';
import 'course_model.dart';

import 'teacher_dashboard.dart'; // <-- ADD

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  final service = TeacherService.instance;

  final Map<int, TextEditingController> _controllers = {};

  List<CourseModel> _courses = [];
  List<StudentModel> _students = [];

  int? _selectedCourseId;
  bool _loading = false;

  void _showSnack(String msg) {
    TeacherDashboard.messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final courses = await service.fetchCourses();
      if (!mounted) return;

      setState(() => _courses = courses);

      if (_courses.isEmpty) {
        _showSnack("No courses in database");
        return;
      }

      final firstId = int.tryParse(_courses.first.id);
      if (firstId == null) throw Exception("Invalid course id");

      setState(() => _selectedCourseId = firstId);

      await _loadForCourse(firstId);
    } catch (e) {
      _showSnack("Init failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _disposeControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  Future<void> _loadForCourse(int courseId) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final students = await service.fetchStudentsByCourse(courseId);
      if (!mounted) return;

      setState(() => _students = students);

      _disposeControllers();
      for (final s in _students) {
        _controllers[s.id] = TextEditingController();
      }

      final marks = await service.fetchMarksByCourse(courseId);
      if (!mounted) return;

      final map = {for (final m in marks) m.studentId: m.mark};

      for (final s in _students) {
        final v = map[s.id];
        _controllers[s.id]!.text = v == null ? "" : v.toStringAsFixed(2);
      }

      if (mounted) setState(() {});
    } catch (e) {
      _showSnack("Load marks failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Future<void> _saveMarks() async {
    final courseId = _selectedCourseId;
    if (courseId == null) return;

    int saved = 0;
    int invalid = 0;

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      for (final s in _students) {
        final txt = _controllers[s.id]!.text.trim();
        if (txt.isEmpty) continue;

        final value = double.tryParse(txt.replaceAll(',', '.'));
        if (value == null) {
          invalid++;
          continue;
        }

        await service.updateMark(
          studentId: s.id,
          courseId: courseId,
          mark: value,
        );
        saved++;

        if (!mounted) return;
      }

      _showSnack(
        "Saved $saved marks (courseId=$courseId)"
            "${invalid > 0 ? " | Invalid: $invalid" : ""}",
      );

      await _loadForCourse(courseId);
    } catch (e) {
      _showSnack("Save failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6A3DE8);

    final availableIds =
    _courses.map((c) => int.tryParse(c.id)).whereType<int>().toSet();
    final dropdownValue =
    (availableIds.contains(_selectedCourseId)) ? _selectedCourseId : null;

    // IMPORTANT: بدون Scaffold داخل tab
    return Column(
      children: [
        Row(
          children: [
            const Text("Course:", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: dropdownValue,
                items: _courses
                    .map((c) => DropdownMenuItem<int>(
                  value: int.tryParse(c.id),
                  child: Text(c.title),
                ))
                    .where((item) => item.value != null)
                    .toList(),
                onChanged: _loading
                    ? null
                    : (v) async {
                  if (v == null) return;
                  setState(() => _selectedCourseId = v);
                  await _loadForCourse(v);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F5FF),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: purple, width: 1.2),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: LinearProgressIndicator(minHeight: 3),
          ),

        Expanded(
          child: _students.isEmpty
              ? const Center(child: Text("No approved students for this course"))
              : ListView.separated(
            padding: const EdgeInsets.only(bottom: 10),
            itemCount: _students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final s = _students[index];
              final ctrl = _controllers[s.id];
              if (ctrl == null) return const SizedBox.shrink();
              return _StudentMarkTile(
                id: s.id,
                name: s.name,
                controller: ctrl,
                enabled: !_loading,
              );
            },
          ),
        ),

        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _saveMarks,
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_loading ? "Please wait..." : "Save Marks"),
          ),
        ),
      ],
    );
  }
}

class _StudentMarkTile extends StatelessWidget {
  final int id;
  final String name;
  final TextEditingController controller;
  final bool enabled;

  const _StudentMarkTile({
    required this.id,
    required this.name,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6A3DE8);

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEDE7FF),
            child: Text(
              name.isEmpty ? "?" : name[0],
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              enabled: enabled,
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Mark",
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF7F5FF),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: purple, width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
