import 'package:flutter/material.dart';
import 'schedule_view.dart';
import 'marks_view.dart';
import 'student_service.dart';
import 'file_model.dart';
import 'auth_service.dart';
import 'user_model.dart';

class StudentPortalScreen extends StatefulWidget {
  const StudentPortalScreen({super.key});

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  int _selectedTab = 0; // 0 Profile, 1 Schedule, 2 Marks, 3 Files

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // même style que AdminPanel
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
              const SizedBox(height: 24),
              const Text(
                'Student Panel',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'View profile, schedule, marks, and files',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
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
                        selectedIndex: _selectedTab,
                        onChanged: (i) => setState(() => _selectedTab = i),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedTab,
                          children: const [
                            _ProfileViewDummy(),
                            ScheduleView(),
                            MarksView(),
                            _FilesDummyView(),
                          ],
                        ),
                      ),
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

// ---------- Tabs pill (même logique que AdminPanel) ----------

class _TabsPill extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabsPill({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F6),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabItem(
                  label: 'Profile',
                  icon: Icons.person,
                  selected: selectedIndex == 0,
                  onTap: () => onChanged(0),
                ),
              ),
              Expanded(
                child: _TabItem(
                  label: 'Schedule',
                  icon: Icons.schedule,
                  selected: selectedIndex == 1,
                  onTap: () => onChanged(1),
                ),
              ),
              Expanded(
                child: _TabItem(
                  label: 'Marks',
                  icon: Icons.grade,
                  selected: selectedIndex == 2,
                  onTap: () => onChanged(2),
                ),
              ),
              Expanded(
                child: _TabItem(
                  label: 'Files',
                  icon: Icons.folder,
                  selected: selectedIndex == 3,
                  onTap: () => onChanged(3),
                ),
              ),
            ],
          ),
        );
      },
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
    const Color accent = Color(0xFF6D28D9);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? accent : Colors.black54,
              ),
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
      ),
    );
  }
}

// ---------- Dummy content (Phase 1) ----------

class _ProfileViewDummy extends StatefulWidget {
  const _ProfileViewDummy();

  @override
  State<_ProfileViewDummy> createState() => _ProfileViewDummyState();
}

class _ProfileViewDummyState extends State<_ProfileViewDummy> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.getLoggedInUser();
    if (!mounted) return;
    setState(() => _user = u);
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
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
                radius: 28,
                backgroundColor: const Color(0xFFEDE7FF),
                child: Text(
                  (u?.name.isNotEmpty ?? false)
                      ? u!.name.substring(0, 2).toUpperCase()
                      : 'ST',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u?.name ?? 'Student Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('Group: ${u?.group ?? 'L2 - ?'}'),
                    Text(
                      'Email: ${u?.email ?? 'student@example.com'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Today',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 10),
        const Text(
          'No events for today. Backend integration in progress.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _FilesDummyView extends StatefulWidget {
  const _FilesDummyView();

  @override
  State<_FilesDummyView> createState() => _FilesDummyViewState();
}

class _FilesDummyViewState extends State<_FilesDummyView> {
  final _service = StudentService.instance;

  bool _loading = true;
  String? _error;
  List<FileModel> _files = [];

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
      final groupKey = user?.group ?? '';

      if (groupKey.isEmpty) {
        if (!mounted) return;
        setState(() {
          _files = [];
          _error = null;
        });
        return;
      }

      final data = await _service.viewFiles(groupKey);
      if (!mounted) return;
      setState(() => _files = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load files: $e');
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

    if (_files.isEmpty) {
      return const Center(child: Text('No files available yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final f = _files[index];
        return Container(
          padding: const EdgeInsets.all(14),
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
              const Icon(Icons.insert_drive_file, color: Colors.black45),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                f.tag,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }
}