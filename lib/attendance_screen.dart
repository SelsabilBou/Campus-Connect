import 'package:flutter/material.dart';
import 'teacher_service.dart';
import 'course_model.dart';
import 'student_model.dart';

// Phase 4: Calendar screen
import 'attendance_calendar_screen.dart';

import 'teacher_dashboard.dart'; // <-- ADD

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final service = TeacherService.instance;

  List<CourseModel> _courses = [];
  List<StudentModel> _students = [];

  int? _selectedCourseId;
  int week = 1;

  bool _loading = false;

  // studentId -> present
  final Map<int, bool> _present = {};

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

  void _resetWeekDefaultsForStudents() {
    _present.clear();
    for (final s in _students) {
      _present[s.id] = true; // default
    }
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

      await _loadCourseAndWeek(courseId: firstId, week: week);
    } catch (e) {
      _showSnack("Init failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCourseAndWeek({
    required int courseId,
    required int week,
  }) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // 1) load students for course
      final students = await service.fetchStudentsByCourse(courseId);
      if (!mounted) return;

      setState(() => _students = students);

      // 2) defaults present=true
      _resetWeekDefaultsForStudents();

      // 3) load attendance records
      for (final s in _students) {
        final rec = await service.getAttendance(
          studentId: s.id,
          courseId: courseId,
          week: week,
        );
        if (!mounted) return;
        if (rec != null) _present[s.id] = rec.present;
      }

      // Optional: refresh UI after async loop
      if (mounted) setState(() {});
    } catch (e) {
      _showSnack("Load attendance failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final cid = _selectedCourseId;
    if (cid == null) return;

    if (!mounted) return;
    setState(() => _loading = true);

    int saved = 0;
    try {
      for (final s in _students) {
        final v = _present[s.id] ?? true;
        await service.markAttendance(
          studentId: s.id,
          courseId: cid,
          week: week,
          present: v,
        );
        saved++;
        if (!mounted) return;
      }

      _showSnack("Attendance saved ($saved) for week $week");
    } catch (e) {
      _showSnack("Save failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _courseNameById(int id) {
    for (final c in _courses) {
      final cid = int.tryParse(c.id);
      if (cid == id) return c.title;
    }
    return "Course";
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6A3DE8);

    return Column(
      children: [
        // Course dropdown
        Row(
          children: [
            const Text("Course:", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedCourseId,
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
                  await _loadCourseAndWeek(courseId: v, week: week);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F5FF),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Week dropdown
        Row(
          children: [
            const Text("Week:", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: week,
                items: List.generate(16, (i) => i + 1)
                    .map((w) => DropdownMenuItem(value: w, child: Text("Week $w")))
                    .toList(),
                onChanged: _loading
                    ? null
                    : (v) async {
                  if (v == null) return;
                  setState(() => week = v);
                  final cid = _selectedCourseId;
                  if (cid != null) {
                    await _loadCourseAndWeek(courseId: cid, week: week);
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F5FF),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFE6DEFF)),
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
              ? const Center(child: Text("No students for this course"))
              : ListView.separated(
            itemCount: _students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final s = _students[index];
              final present = _present[s.id] ?? false;

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
                    Expanded(
                      child: Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Switch(
                      value: present,
                      activeColor: purple,
                      onChanged: _loading
                          ? null
                          : (v) => setState(() => _present[s.id] = v),
                    ),
                    Text(
                      present ? "Present" : "Absent",
                      style: TextStyle(
                        color: present ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Calendar button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _loading || _selectedCourseId == null
                ? null
                : () {
              final cid = _selectedCourseId!;
              final name = _courseNameById(cid);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceCalendarScreen(
                    courseId: cid,
                    courseName: name,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: purple,
              side: const BorderSide(color: purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Calendar View"),
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_loading ? "Please wait..." : "Save Attendance"),
          ),
        ),
      ],
    );
  }
}
