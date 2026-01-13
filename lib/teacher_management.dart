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
  List<Map<String, dynamic>> groups = []; // [{id,title}] - pas utilisé maintenant
  List<String> availableGroups = []; // 👈 NOUVEAU: Liste des noms de groupes

  bool loading = false;
  bool loadingGroups = false;
  String? errorMsg;

  int? selectedTeacherId;
  String? selectedGroupId;

  @override
  void initState() {
    super.initState();
    loadData();
    loadAvailableGroups(); // 👈 NOUVEAU: Charge les groupes disponibles
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      teachers = await service.fetchTeachers();
      groups = await service.fetchGroupsRaw(); // Garde pour compatibilité
    } catch (e) {
      errorMsg = "Erreur lors du chargement";
    }

    if (mounted) setState(() => loading = false);
  }

  // 👇 NOUVELLE FONCTION: Charge les groupes distincts
  Future<void> loadAvailableGroups() async {
    setState(() => loadingGroups = true);

    try {
      final fetchedGroups = await service.fetchAvailableGroups();
      if (mounted) {
        setState(() {
          availableGroups = fetchedGroups;
          loadingGroups = false;
        });
        print('✅ Available groups loaded: $availableGroups');
      }
    } catch (e) {
      print('❌ Error loading available groups: $e');
      if (mounted) {
        setState(() {
          // Fallback en cas d'erreur
          availableGroups = [
            'L2 - Group 1',
            'L2 - Group 2',
            'L3 - Group 1',
            'L3 - Group 2',
          ];
          loadingGroups = false;
        });
      }
    }
  }

  Future<void> assignGroup() async {
    if (selectedTeacherId == null || selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un teacher et un groupe')),
      );
      return;
    }

    setState(() => loading = true);
    final r = await service.assignGroupToTeacher(
      selectedTeacherId!,
      selectedGroupId!,
    );
    setState(() => loading = false);

    if (!mounted) return;

    // Notification (success/fail) avec message PHP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.success ? "✅ ${r.message}" : "❌ ${r.message}"),
        backgroundColor: r.success ? Colors.green : Colors.red,
      ),
    );

    if (r.success) {
      // Reset selections
      setState(() {
        selectedTeacherId = null;
        selectedGroupId = null;
      });
      await loadData(); // refresh باش تبان group_title يتبدل
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        backgroundColor: const Color(0xFF6D28D9),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign group',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            if (loading) const LinearProgressIndicator(),

            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadData,
                child: const Text("Retry"),
              ),
              const SizedBox(height: 10),
            ],

            Expanded(
              child: teachers.isEmpty
                  ? const Center(
                child: Text('No teachers found'),
              )
                  : ListView.separated(
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
                          color: isSelected
                              ? const Color(0xFF6D28D9)
                              : Colors.transparent,
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
                                  'Group: $groupTitle',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF6D28D9),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 👇 DROPDOWN MODIFIÉ: Utilise availableGroups au lieu de groups
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: loadingGroups
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : DropdownButton<String>(
                      value: selectedGroupId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Select Group'),
                      items: availableGroups.isEmpty
                          ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No groups available'),
                        )
                      ]
                          : availableGroups.map((groupName) {
                        return DropdownMenuItem<String>(
                          value: groupName,
                          child: Text(groupName),
                        );
                      }).toList(),
                      onChanged: availableGroups.isEmpty
                          ? null
                          : (v) => setState(() => selectedGroupId = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D28D9),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: (loading ||
                          loadingGroups ||
                          selectedTeacherId == null ||
                          selectedGroupId == null)
                          ? null
                          : assignGroup,
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
          ],
        ),
      ),
    );
  }
}
