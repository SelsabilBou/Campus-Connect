import 'package:flutter/material.dart';
import 'student_service.dart';
import 'auth_service.dart';
class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _service = StudentService.instance;

  bool _loading = true;
  String? _error;
  List<Map<String, String>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await AuthService.getLoggedInUser();
      if (user == null || user.group.isEmpty) {
        if (!mounted) return;
        setState(() {
          _items = [];
          _error = null;
        });
        return;
      }

      final data = await _service.viewSchedule(user.group);
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load schedule: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No schedule available yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final row = _items[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text('${row['day']} - ${row['course']}'),
            subtitle: Text(row['time'] ?? ''),
          ),
        );
      },
    );
  }
}
