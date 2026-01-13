import 'package:flutter/material.dart';
import 'admin_service.dart';

class TeacherCourseAssignScreen extends StatefulWidget {
  const TeacherCourseAssignScreen({super.key});

  @override
  State<TeacherCourseAssignScreen> createState() =>
      _TeacherCourseAssignScreenState();
}

class _TeacherCourseAssignScreenState
    extends State<TeacherCourseAssignScreen> {
  final service = AdminService.instance;

  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> courses = []; // [{id,title}]
  bool loading = false;
  String? errorMsg;

  int? selectedTeacherId;
  String? selectedCourseId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      teachers = await service.fetchTeachers();
      courses = await service.fetchCoursesRaw();
    } catch (e) {
      errorMsg = "Erreur lors du chargement";
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> assignCourse() async {
    if (selectedTeacherId == null || selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis un teacher et un cours'),
        ),
      );
      return;
    }

    setState(() => loading = true);
    final r = await service.assignCourseToTeacher(
      selectedTeacherId!,
      selectedCourseId!,
    );
    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          r.success ? "✅ ${r.message}" : "❌ ${r.message}",
        ),
      ),
    );

    if (r.success) {
      // on recharge pour que la liste des cours s’actualise
      await loadData();
      setState(() {
        selectedTeacherId = null;
        selectedCourseId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign course to teacher')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign course',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            if (loading) const LinearProgressIndicator(),

            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMsg!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadData,
                child: const Text("Retry"),
              ),
              const SizedBox(height: 10),
            ],

            Expanded(
              child: teachers.isEmpty
                  ? const Center(child: Text('No teachers found'))
                  : ListView.separated(
                itemCount: teachers.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = teachers[index];

                  final id = int.parse(t['id'].toString());
                  final name = (t['name'] ?? '').toString();
                  final email = (t['email'] ?? '').toString();
                  // 👇 texte concaténé envoyé par teachers_read.php
                  final coursesTitles =
                  (t['courses_titles'] ?? '-').toString();

                  final initials = name
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e[0])
                      .join();

                  final isSelected = selectedTeacherId == id;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => selectedTeacherId = id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6D28D9)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                            const Color(0xFFEDE7FF),
                            child: Text(
                              initials.isEmpty ? "?" : initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Courses: $coursesTitles',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCourseId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Select course'),
                      items: courses.map((c) {
                        final cid = c['id'].toString();
                        final title = c['title'].toString();
                        return DropdownMenuItem(
                          value: cid,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => selectedCourseId = v),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: loading ? null : assignCourse,
                    child: const Text(
                      'Assign',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
