// student_all_screen.dart
import 'package:flutter/material.dart';
import 'admin_service.dart';

class StudentAllScreen extends StatefulWidget {
  const StudentAllScreen({super.key});

  @override
  State<StudentAllScreen> createState() => _StudentAllScreenState();
}

class _StudentAllScreenState extends State<StudentAllScreen> {
  final service = AdminService.instance;

  List<Map<String, dynamic>> students = [];
  bool loading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      // students_read.php : tous les étudiants approuvés
      final uri = service.buildUri(
        'students_read.php',
        query: {
          'course_id': '0',
          'page': '1',
          'limit': '200',
        },
      );

      final res = await service.getRaw(uri);

      if (res.statusCode != 200) {
        errorMsg = 'HTTP ${res.statusCode}';
        students = [];
      } else {
        students = service.decodeList(res.body);
      }
    } catch (e) {
      errorMsg = 'Erreur lors du chargement';
      students = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteStudent(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text("Supprimer l'étudiant $name ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);
    final r = await service.deleteStudent(id);
    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.message)),
    );

    if (r.success) {
      await _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All students',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        if (loading)
          const LinearProgressIndicator(minHeight: 3),
        if (errorMsg != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMsg!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadStudents,
            child: const Text('Retry'),
          ),
        ],
        const SizedBox(height: 8),
        Expanded(
          child: students.isEmpty
              ? const Center(child: Text('No students'))
              : ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final s = students[index];
              final id = int.parse(s['id'].toString());
              final name = (s['name'] ?? '').toString();
              final email = (s['email'] ?? '').toString();

              final initials = name
                  .split(' ')
                  .where((e) => e.isNotEmpty)
                  .take(2)
                  .map((e) => e[0])
                  .join();

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
                      radius: 24,
                      backgroundColor: const Color(0xFFEDE7FF),
                      child: Text(
                        initials.isEmpty ? '?' : initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteStudent(id, name),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
