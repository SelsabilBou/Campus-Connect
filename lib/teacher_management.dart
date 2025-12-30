import 'package:flutter/material.dart';
import 'admin_service.dart';

class TeacherManagement extends StatefulWidget {
  const TeacherManagement({super.key});

  @override
  State<TeacherManagement> createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement> {
  final service = AdminService.instance;

  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> groups = []; // [{id,title}]
  bool loading = false;
  String? errorMsg;

  int? selectedTeacherId;
  String? selectedGroupId;

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
      groups = await service.fetchGroupsRaw();
    } catch (e) {
      errorMsg = "Erreur lors du chargement";
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> assignGroup() async {
    if (selectedTeacherId == null || selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un teacher et un groupe')),
      ); // [web:225]
      return;
    }

    setState(() => loading = true);
    final r = await service.assignGroupToTeacher(selectedTeacherId!, selectedGroupId!); // ApiResult
    setState(() => loading = false);

    if (!mounted) return;

    // Notification (success/fail) avec message PHP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.success ? "✅ ${r.message}" : "❌ ${r.message}")),
    ); // [web:225]

    if (r.success) {
      await loadData(); // refresh باش تبان group_title يتبدل
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assign group', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            if (loading) const LinearProgressIndicator(),

            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: loadData, child: const Text("Retry")),
              const SizedBox(height: 10),
            ],

            Expanded(
              child: ListView.separated(
                itemCount: teachers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = teachers[index];

                  final id = int.parse(t['id'].toString());
                  final name = (t['name'] ?? '').toString();
                  final email = (t['email'] ?? '').toString();
                  final groupTitle = (t['group_title'] ?? '-').toString();

                  final initials = name
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e[0])
                      .join();

                  final isSelected = selectedTeacherId == id;

                  return GestureDetector(
                    onTap: () => setState(() => selectedTeacherId = id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6D28D9) : Colors.transparent,
                          width: 2,
                        ),
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
                            radius: 26,
                            backgroundColor: const Color(0xFFEDE7FF),
                            child: Text(
                              initials.isEmpty ? "?" : initials,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(email, style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 4),
                                Text('Group: $groupTitle', style: const TextStyle(color: Colors.black45)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButton<String>(
                      value: selectedGroupId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Select Group'),
                      items: groups.map((g) {
                        final gid = g['id'].toString();
                        final title = g['title'].toString();
                        return DropdownMenuItem(
                          value: gid,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedGroupId = v),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    onPressed: loading ? null : assignGroup,
                    child: const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
