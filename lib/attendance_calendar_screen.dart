import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';//package te3 calendrier
import 'teacher_service.dart';//service te lprof beh njibou data mn backend
import 'student_model.dart';//class tefhem structure te3 student
//declaration te3 Widget
class AttendanceCalendarScreen extends StatefulWidget {
  final int courseId;//id te3 la matiere
  final String courseName;//name te3 la matiere
//le constructeur
  const AttendanceCalendarScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}
class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  final service = TeacherService.instance;//bech njib data mn backend

  DateTime _focusedDay = DateTime.now();//date current te lyoum
  DateTime? _selectedDay;//nhar li selectineh

  List<StudentModel> _students = [];//liste te3 les etudent te3 tel matiere
  bool _loading = false;//false bech n3rfou ida loading wla lela

  final Map<DateTime, List<String>> _events = {};//kol nhar dateTIME endou liste te3 events

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);//exemple 2026/01/12


  DateTime _dateForWeek(int year, int week) {//fontion pour recuperer la date sous forme de weeks
    final jan1 = DateTime(year, 1, 1);//awel nhar fl 3em
    final mondayOffset = (DateTime.monday - jan1.weekday) % 7;//y7seb gdeh ba9i nhar hta awel monday
    final firstMonday = jan1.add(Duration(days: mondayOffset));//nzidou les jours beh nouslou l tnin
    return firstMonday.add(Duration(days: (week - 1) * 7));//nziodu les jours beh nouslou l nhar li habin
  }

  Future<void> _loadCalendarData() async {
    setState(() => _loading = true);//bech nkhaliw progress indicator
    try {
      _students = await service.fetchStudentsByCourse(widget.courseId);//njibou tous les etudients te3 hed la matiere mn backend

      _events.clear();//nfrghou lmap te3 event beh nbdewmn lowl
      final year = DateTime.now().year;//annee current

      // 16 week psq keml semester
      for (int week = 1; week <= 16; week++) {
        final day = _dayKey(_dateForWeek(year, week));//n7sbou tarikh te3 hed l week

        int presentCount = 0;//des variable de comptage
        int absentCount = 0;
        //recuperation te3 attendance te3 l'etudiant lhed lweek
        for (final s in _students) {
          final rec = await service.getAttendance(
            studentId: s.id,
            courseId: widget.courseId,
            week: week,
          );
          if (rec == null) continue;
          if (rec.present) presentCount++;//ida present nzidou 1
          else absentCount++;//ida absent nzidou 1
        }

        if (presentCount == 0 && absentCount == 0) continue;
          //map te3 strings beh nzidou event
        _events[day] = [
          "Week $week",
          "Present: $presentCount",
          "Absent: $absentCount",
        ];
      }
    } finally {//ma3naha dima tetnafed even error
      if (mounted) setState(() => _loading = false);//ida widget mazel mounted nraj3ou loading =false
    }
  }

  List<String> _getEventsForDay(DateTime day) => _events[_dayKey(day)] ?? const [];//ndakhlou nhar w nkharjou liste te3 event te3ou

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
