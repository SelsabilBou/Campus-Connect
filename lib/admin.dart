// admin_panal.dart (sans bouton Open : les tabs ouvrent directement les écrans)
import 'package:flutter/material.dart';
import 'student_management.dart';
import 'teacher_management.dart';
import 'file_upload.dart';
import 'schedule_calender.dart';
import 'auth_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int selectedTab = 0; // 0 Students, 1 Teachers, 2 Files

  @override
  void initState() {
    super.initState();
    _guardAdmin();
  }

  Future<void> _guardAdmin() async {
    final logged = await AuthService.isLoggedIn();
    final role = await AuthService.getUserRole();

    if (!mounted) return;

    if (!logged || role != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Accès refusé : Admin فقط")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // au lieu de IndexedStack + carte avec bouton Open,
    // on ouvre directement l'écran selon selectedTab
    Widget bodyChild;
    if (selectedTab == 0) {
      bodyChild = const StudentManagement();
    } else if (selectedTab == 1) {
      bodyChild = const TeacherManagement();
    } else {
      bodyChild = const _FilesTab();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBFA8FF), Color(0xFF6D28D9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await AuthService.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/welcome',
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage campus data',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: Container
                  (
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      _TabsPill(
                        selectedIndex: selectedTab,
                        onChanged: (i) => setState(() => selectedTab = i),
                      ),
                      const SizedBox(height: 16),
                      // ici on montre directement l'écran correspondant au tab
                      Expanded(child: bodyChild),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabsPill extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabsPill({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Students',
              icon: Icons.person,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Teachers',
              icon: Icons.school,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Files',
              icon: Icons.folder,
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF6D28D9) : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? const Color(0xFF6D28D9) : Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Files tab reste comme avant
class _FilesTab extends StatelessWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: const [
              _FileCard(name: 'timetable_groupA.png', tag: 'Timetable'),
              _FileCard(name: 'syllabus', tag: 'Timetable'),
              _FileCard(name: 'syllabus_BD.pdf', tag: 'Timetable'),
              _FileCard(name: 'exam_schedule.xlsx', tag: 'Exam'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FileUploadPage()),
            );
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF6D28D9),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text(
                'Upload',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScheduleCalendarPage()),
            );
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text(
                'Calendar',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Files + Calendar', style: TextStyle(color: Colors.black45)),
      ],
    );
  }
}

class _FileCard extends StatelessWidget {
  final String name;
  final String tag;

  const _FileCard({required this.name, required this.tag});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const Spacer(),
          const Icon(Icons.insert_drive_file, color: Colors.black45),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
