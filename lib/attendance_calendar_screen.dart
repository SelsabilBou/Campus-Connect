import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'teacher_service.dart';
import 'student_model.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const AttendanceCalendarScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  final service = TeacherService.instance;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<StudentModel> _students = [];
  bool _loading = false;

  // dayKey => list of strings (events)
  final Map<DateTime, List<String>> _events = {};

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  // Week -> date (simple mapping: week 1 = first Monday of year)
  DateTime _dateForWeek(int year, int week) {
    final jan1 = DateTime(year, 1, 1);
    final mondayOffset = (DateTime.monday - jan1.weekday) % 7;
    final firstMonday = jan1.add(Duration(days: mondayOffset));
    return firstMonday.add(Duration(days: (week - 1) * 7));
  }

  Future<void> _loadCalendarData() async {
    setState(() => _loading = true);
    try {
      _students = await service.fetchStudentsByCourse(widget.courseId);

      _events.clear();
      final year = DateTime.now().year;

      // weeks 1..16 (كيما عندك)
      for (int week = 1; week <= 16; week++) {
        final day = _dayKey(_dateForWeek(year, week));

        int presentCount = 0;
        int absentCount = 0;

        for (final s in _students) {
          final rec = await service.getAttendance(
            studentId: s.id,
            courseId: widget.courseId,
            week: week,
          );
          if (rec == null) continue;
          if (rec.present) presentCount++;
          else absentCount++;
        }

        if (presentCount == 0 && absentCount == 0) continue;

        _events[day] = [
          "Week $week",
          "Present: $presentCount",
          "Absent: $absentCount",
        ];
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _getEventsForDay(DateTime day) => _events[_dayKey(day)] ?? const [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.courseName} - Calendar")),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 3),
          TableCalendar<String>(
            firstDay: DateTime(DateTime.now().year, 1, 1),
            lastDay: DateTime(DateTime.now().year, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map((e) => ListTile(title: Text(e)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
