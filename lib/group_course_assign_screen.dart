import 'package:flutter/material.dart';
import 'admin_service.dart';

class GroupCourseAssignScreen extends StatefulWidget {
  const GroupCourseAssignScreen({super.key});

  @override
  State<GroupCourseAssignScreen> createState() =>
      _GroupCourseAssignScreenState();
}

class _GroupCourseAssignScreenState extends State<GroupCourseAssignScreen> {
  final service = AdminService.instance;

  List<Map<String, dynamic>> groups = [];   // [{id, title, ...}]
  List<Map<String, dynamic>> courses = [];  // [{id, title, ...}]
  bool loading = false;
  String? errorMsg;

  String? selectedGroupId;
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
      final g = await service.fetchGroupsRaw();
      final c = await service.fetchCoursesRaw();

      setState(() {
        groups = g;
        courses = c;

        // Réinitialiser la sélection si les listes ont changé
        if (groups.isEmpty) {
          selectedGroupId = null;
        } else if (selectedGroupId != null &&
            !groups.any((e) => e['id'].toString() == selectedGroupId)) {
          selectedGroupId = null;
        }

        if (courses.isEmpty) {
          selectedCourseId = null;
        } else if (selectedCourseId != null &&
            !courses.any((e) => e['id'].toString() == selectedCourseId)) {
          selectedCourseId = null;
        }
      });
    } catch (e) {
      setState(() {
        errorMsg = "Erreur lors du chargement";
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> assignCourse() async {
    if (selectedGroupId == null || selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis un groupe et un cours'),
        ),
      );
      return;
    }

    setState(() => loading = true);
    final r = await service.assignCourseToGroup(
      selectedGroupId!,
      selectedCourseId!,
    );
    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          r.success ? "${r.message}" : " ${r.message}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool noGroups = groups.isEmpty;
    final bool noCourses = courses.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign course to group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign course to group',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            if (loading) const LinearProgressIndicator(),

            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMsg!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadData,
                child: const Text("Retry"),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 8),
            const Text(
              'Select group',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButton<String>(
                value: selectedGroupId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  noGroups ? 'No groups found' : 'Select group',
                ),
                items: groups.map((g) {
                  final gid = g['id'].toString();
                  final title = (g['title'] ?? '').toString();
                  return DropdownMenuItem<String>(
                    value: gid,
                    child: Text(title.isEmpty ? 'Group $gid' : title),
                  );
                }).toList(),
                onChanged: noGroups
                    ? null
                    : (v) => setState(() => selectedGroupId = v),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Select course',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButton<String>(
                value: selectedCourseId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  noCourses ? 'No courses found' : 'Select course',
                ),
                items: courses.map((c) {
                  final cid = c['id'].toString();
                  final title = (c['title'] ?? '').toString();
                  return DropdownMenuItem<String>(
                    value: cid,
                    child: Text(title.isEmpty ? 'Course $cid' : title),
                  );
                }).toList(),
                onChanged: noCourses
                    ? null
                    : (v) => setState(() => selectedCourseId = v),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
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
      ),
    );
  }
}
