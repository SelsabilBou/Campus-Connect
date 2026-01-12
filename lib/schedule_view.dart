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

  // 🔍 NEW
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, String>> _allItems = [];
  List<Map<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await AuthService.getLoggedInUser();
      if (user == null || user.grp.isEmpty) {
        if (!mounted) return;
        setState(() {
          _allItems = [];
          _filteredItems = [];
          _error = null;
        });
        return;
      }

      final data = await _service.viewSchedule(user.grp);
      if (!mounted) return;
      setState(() {
        _allItems = data;
        _applyFilter(); // initialise la liste filtrée
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load schedule: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredItems = List<Map<String, String>>.from(_allItems);
    } else {
      _filteredItems = _allItems.where((row) {
        final day = (row['day'] ?? '').toLowerCase();
        final course = (row['course'] ?? '').toLowerCase();
        final time = (row['time'] ?? '').toLowerCase();
        return day.contains(q) || course.contains(q) || time.contains(q);
      }).toList();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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

    if (_allItems.isEmpty) {
      return const Center(child: Text('No schedule available yet.'));
    }

    return Column(
      children: [
        // 🔍 Barre de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by day, course, or time...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _filteredItems.isEmpty
              ? const Center(child: Text('No schedule matches your search.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredItems.length,
            itemBuilder: (context, i) {
              final row = _filteredItems[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('${row['day']} - ${row['course']}'),
                  subtitle: Text(row['time'] ?? ''),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
