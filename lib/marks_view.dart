import 'package:flutter/material.dart';
import 'student_service.dart';
import 'auth_service.dart';

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

      if (user == null || user.id == null) {
        if (!mounted) return;
        setState(() {
          _marks = [];
          _error = null;
          _loading = false;
        });
        return;
      }

      // Check if student is approved
      if (user.status?.toLowerCase() == 'pending') {
        if (!mounted) return;
        setState(() {
          _marks = [];
          _error = null;
          _loading = false;
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
    const purple = Color(0xFF6A3DE8);
    const lightPurple = Color(0xFFF3F0FF);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_marks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No marks available yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your marks will appear here once published',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _marks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final mark = _marks[index];
        final courseName = mark['course']?.toString() ?? 'Unknown Course';
        final cc = mark['cc']?.toString() ?? 'N/A';
        final exam = mark['exam']?.toString() ?? 'N/A';

        // Calculate average if both marks are available
        double? average;
        final ccNum = double.tryParse(cc);
        final examNum = double.tryParse(exam);
        if (ccNum != null && examNum != null) {
          average = (ccNum + examNum) / 2;
        }

        return Container(
          padding: const EdgeInsets.all(16),
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
              // Course name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.book_outlined,
                      color: purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Marks row
              Row(
                children: [
                  Expanded(
                    child: _MarkCard(
                      label: 'CC',
                      value: cc,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MarkCard(
                      label: 'Exam',
                      value: exam,
                      color: Colors.orange,
                    ),
                  ),
                  if (average != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MarkCard(
                        label: 'Average',
                        value: average.toStringAsFixed(2),
                        color: purple,
                        isBold: true,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MarkCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _MarkCard({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
