import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleCalendarPage extends StatefulWidget {
  const ScheduleCalendarPage({super.key});

  @override
  State<ScheduleCalendarPage> createState() => _ScheduleCalendarPageState();
}

class _ScheduleCalendarPageState extends State<ScheduleCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Basic schedules (local)
  final Map<DateTime, List<String>> _events = {};

  List<String> get _selectedEvents {
    final day = _selectedDay ?? DateTime.now();
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  void _addEvent() async {
    final ctrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un événement"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "Ex: Exam BD 10:00"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ajouter")),
        ],
      ),
    );

    final text = ctrl.text.trim();
    if (ok != true || text.isEmpty) return;

    final day = _selectedDay ?? DateTime.now();
    final key = DateTime(day.year, day.month, day.day);

    setState(() {
      _events.putIfAbsent(key, () => []);
      _events[key]!.add(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar / Schedules"),
        actions: [
          IconButton(onPressed: _addEvent, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
            child: _selectedEvents.isEmpty
                ? const Center(child: Text("Aucun événement pour ce jour."))
                : ListView.separated(
              itemCount: _selectedEvents.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                title: Text(_selectedEvents[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
