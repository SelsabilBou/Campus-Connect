import 'package:flutter/material.dart';
import 'schedule_view.dart';
import 'marks_view.dart';
import 'student_service.dart';
import 'file_model.dart';
import 'auth_service.dart';
import 'user_model.dart';
import 'chat_screen.dart'; // 👈 NEW
import 'event_service.dart';
import 'event_model.dart';

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

// ---------- Profile (avec bouton Chat) ----------

class _ProfileViewDummy extends StatefulWidget {
  const _ProfileViewDummy();

  @override
  State<_ProfileViewDummy> createState() => _ProfileViewDummyState();
}

class _ProfileViewDummyState extends State<_ProfileViewDummy> {
  UserModel? _user;
  List<EventModel> _events = [];
  bool _loadingEvents = true;
  String? _eventsError;

  @override
  void initState() {
    super.initState();
    _loadUserAndEvents();
  }

  Future<void> _loadUserAndEvents() async {
    try {
      final u = await AuthService.getLoggedInUser();
      if (!mounted) return;
      setState(() => _user = u);

      if (u == null || u.group.isEmpty) {
        setState(() {
          _events = [];
          _eventsError = null;
          _loadingEvents = false;
        });
        return;
      }

      final data =
      await EventService.instance.fetchEventsForGroup(u.group);
      if (!mounted) return;
      setState(() {
        _events = data;
        _eventsError = null;
        _loadingEvents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _eventsError = 'Failed to load events: $e';
        _loadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ----- Card profil -----
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

        // ----- Events / Exams -----
        if (_loadingEvents)
          const Center(child: CircularProgressIndicator())
        else if (_eventsError != null)
          Text(
            _eventsError!,
            style: const TextStyle(color: Colors.red),
          )
        else if (_events.isEmpty)
            const Text(
              'No events for today. Backend integration in progress.',
              style: TextStyle(color: Colors.black54),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _events.map((e) {
                final dateStr =
                    '${e.eventDate.year}-${e.eventDate.month.toString().padLeft(2, '0')}-${e.eventDate.day.toString().padLeft(2, '0')} '
                    '${e.eventDate.hour.toString().padLeft(2, '0')}:${e.eventDate.minute.toString().padLeft(2, '0')}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      if (e.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          e.description,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),

        const SizedBox(height: 20),

        // ----- Bouton chat (si tu l’as gardé) -----
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatScreen(
                  otherUserId: 5,
                  otherUserName: 'Samir',
                ),
              ),
            );
          },
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Open chat with Samir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D28D9),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ---------- Files avec Search ----------

class _FilesDummyView extends StatefulWidget {
  const _FilesDummyView();

  @override
  State<_FilesDummyView> createState() => _FilesDummyViewState();
}

class _FilesDummyViewState extends State<_FilesDummyView> {
  final _service = StudentService.instance;

  bool _loading = true;
  String? _error;

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<FileModel> _allFiles = [];
  List<FileModel> _filteredFiles = [];

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _scrollCtrl.addListener(_onScroll);
    _load(firstPage: true);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({required bool firstPage}) async {
    if (firstPage) {
      setState(() {
        _loading = true;
        _error = null;
        _allFiles.clear();
        _filteredFiles.clear();
        _page = 1;
        _hasMore = true;
      });
    }

    try {
      final user = await AuthService.getLoggedInUser();
      final groupKey = user?.group ?? '';

      if (groupKey.isEmpty) {
        if (!mounted) return;
        setState(() {
          _allFiles.clear();
          _filteredFiles.clear();
          _error = null;
          _loading = false;
          _hasMore = false;
        });
        return;
      }

      final result =
      await _service.viewFilesPaged(groupKey, _page, _limit);

      if (!mounted) return;

      setState(() {
        _allFiles.addAll(result.files);
        _hasMore = result.hasMore;
        _page++;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load files: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _loading) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      _load(firstPage: false);
    }
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchCtrl.text.trim().toLowerCase();
    List<FileModel> base = List<FileModel>.from(_allFiles);

    if (query.isNotEmpty) {
      base = base.where((f) {
        final name = f.name.toLowerCase();
        final tag = f.tag.toLowerCase();
        return name.contains(query) || tag.contains(query);
      }).toList();
    }

    _filteredFiles = base;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _allFiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _allFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _load(firstPage: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name or tag...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _allFiles.isEmpty
              ? const Center(child: Text('No files available yet.'))
              : (_filteredFiles.isEmpty
              ? const Center(
            child: Text('No files match your search.'),
          )
              : ListView.separated(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount:
            _filteredFiles.length + (_hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == _filteredFiles.length && _hasMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final f = _filteredFiles[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
                    const Icon(Icons.insert_drive_file,
                        color: Colors.black45),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.tag,
                      style: const TextStyle(
                          color: Colors.black54),
                    ),
                  ],
                ),
              );
            },
          )),
        ),
      ],
    );
  }
}
