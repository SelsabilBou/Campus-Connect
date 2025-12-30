import 'package:flutter/material.dart';
import 'student_service.dart';
import 'auth_service.dart';
import 'user_model.dart';

class MarksView extends StatefulWidget {
  const MarksView({super.key});

  @override
  State<MarksView> createState() => _MarksViewState();
}

class _MarksViewState extends State<MarksView> {
  final _service = StudentService.instance;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _marks = [];

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

      // Si pas encore de login complet, on affiche juste un message neutre
      if (user == null || user.id == null) {
        if (!mounted) return;
        setState(() {
          _marks = [];
          _error = null; // pas une vraie erreur
        });
        return;
      }

      final data = await _service.viewMarks(user.id!);
      if (!mounted) return;
      setState(() => _marks = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load marks: $e');
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

    if (_marks.isEmpty) {
      return const Center(child: Text('No marks available yet.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Course')),
            DataColumn(label: Text('CC')),
            DataColumn(label: Text('Exam')),
          ],
          rows: _marks
              .map(
                (m) => DataRow(
              cells: [
                DataCell(Text(m['course'].toString())),
                DataCell(Text(m['cc'].toString())),
                DataCell(Text(m['exam'].toString())),
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
