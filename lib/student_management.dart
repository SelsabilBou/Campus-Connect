import 'package:flutter/material.dart';
import 'admin_service.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  final service = AdminService.instance;

  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> pendingAll = [];
  List<Map<String, dynamic>> pendingView = [];

  bool loading = false;
  String? errorMsg;

  // Phase 5: pagination
  final int _limit = 20;
  int _offset = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    loadPending(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> loadPending({required bool reset}) async {
    if (loading) return;

    setState(() {
      loading = true;
      errorMsg = null;
      if (reset) {
        _offset = 0;
        _hasMore = true;
      }
    });

    try {
      final list = await service.fetchPendingStudents(limit: _limit, offset: _offset);

      if (reset) {
        pendingAll = list;
      } else {
        pendingAll.addAll(list);
      }

      // إذا رجعت أقل من limit => ماكانش pages أخرى
      if (list.length < _limit) _hasMore = false;

      // جهّز الصفحة للعرض حسب search الحالي
      _applyFilter(_searchCtrl.text);

      // update offset للpage الجاية
      _offset = pendingAll.length;
    } catch (e) {
      errorMsg = "Erreur lors du chargement";
    }

    if (mounted) setState(() => loading = false);
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      pendingView = List<Map<String, dynamic>>.from(pendingAll);
      return;
    }

    pendingView = pendingAll.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  List<String> _buildSuggestions(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final matches = pendingAll.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    return matches
        .map((s) => "${(s['name'] ?? '').toString()} — ${(s['email'] ?? '').toString()}")
        .toSet()
        .take(6)
        .toList();
  }

  Future<void> approve(int id) async {
    setState(() => loading = true);
    final r = await service.approveStudent(id); // ApiResult
    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.success ? "✅ ${r.message}" : "❌ ${r.message}")),
    ); // [web:225][web:313]

    if (r.success) {
      // نعاود نحمّل من الأول باش تبان update صحيح
      await loadPending(reset: true);
    }
  }

  Future<void> reject(int id) async {
    setState(() => loading = true);
    final r = await service.rejectStudent(id); // ApiResult
    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.success ? "✅ ${r.message}" : "❌ ${r.message}")),
    ); // [web:225][web:313]

    if (r.success) {
      await loadPending(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool filtering = _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending registrations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue value) {
                return _buildSuggestions(value.text);
              },
              onSelected: (String selected) {
                _searchCtrl.text = selected;
                setState(() => _applyFilter(selected));
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                controller.value = _searchCtrl.value;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F6),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: focusNode,
                    onChanged: (v) => setState(() => _applyFilter(v)),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search),
                      hintText: 'Search name/email',
                      border: InputBorder.none,
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _applyFilter(''));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            if (loading) const LinearProgressIndicator(),

            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => loadPending(reset: true),
                child: const Text("Retry"),
              ),
            ],

            Expanded(
              child: ListView.separated(
                itemCount: pendingView.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = pendingView[index];

                  final name = (s['name'] ?? '').toString();
                  final email = (s['email'] ?? '').toString();
                  final id = int.parse(s['id'].toString());

                  final initials = name
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e[0])
                      .join();

                  return _UserCard(
                    initials: initials.isEmpty ? "?" : initials,
                    name: name,
                    email: email,
                    onApprove: loading ? () {} : () => approve(id),
                    onReject: loading ? () {} : () => reject(id),
                  );
                },
              ),
            ),

            // Phase 5: Load more (simple)
            if (!filtering && _hasMore) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : () => loadPending(reset: false),
                  child: Text(loading ? "Loading..." : "Load more"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _UserCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              onPressed: onApprove,
              child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6D28D9), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              onPressed: onReject,
              child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
