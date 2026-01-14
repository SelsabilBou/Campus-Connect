import 'dart:async';
import 'package:flutter/material.dart';

import 'teacher_service.dart';
import 'student_model.dart';
import 'teacher_dashboard.dart';

class CourseStudentsScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const CourseStudentsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseStudentsScreen> createState() => _CourseStudentsScreenState();
}

class _CourseStudentsScreenState extends State<CourseStudentsScreen> {
  final service = TeacherService.instance;

  // Pagination
  final int _limit = 50;
  int _page = 1;
  bool _hasMore = true;

  bool _loadingFirst = false;
  bool _loadingMore = false;

  final List<StudentModel> _students = [];

  // Scroll
  final ScrollController _scrollCtrl = ScrollController();

  // SEARCH
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = "";

  List<StudentModel> get _filteredStudents {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _students;

    return _students.where((s) {
      final name = s.name.toLowerCase();
      final id = s.id.toString();
      return name.contains(q) || id.contains(q);
    }).toList();
  }

  void _showSnack(String msg) {
    TeacherDashboard.messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = v);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingFirst || _loadingMore) return;
    if (!_scrollCtrl.hasClients) return;

    const threshold = 200.0;
    final max = _scrollCtrl.position.maxScrollExtent;
    final cur = _scrollCtrl.position.pixels;

    if (max - cur <= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    if (!mounted) return;
    setState(() {
      _loadingFirst = true;
      _loadingMore = false;
      _hasMore = true;
      _page = 1;
      _students.clear();
    });

    try {
      final res = await service.fetchStudentsByCourse(
        widget.courseId,
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;
      setState(() {
        _students.addAll(res);
        _hasMore = res.length == _limit;
        _page = 2;
      });
    } catch (e) {
      _showSnack("Load students failed: $e");
    } finally {
      if (mounted) setState(() => _loadingFirst = false);
    }
  }

  Future<void> _loadNextPage() async {
    if (!mounted) return;
    setState(() => _loadingMore = true);

    try {
      final res = await service.fetchStudentsByCourse(
        widget.courseId,
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;
      setState(() {
        _students.addAll(res);
        _hasMore = res.length == _limit;
        _page += 1;
      });
    } catch (e) {
      _showSnack("Load more failed: $e");
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        actions: [
          IconButton(
            onPressed: _loadingFirst ? null : _loadFirstPage,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          if (_loadingFirst) const LinearProgressIndicator(minHeight: 3),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search students (name/id)...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.trim().isEmpty
                    ? null
                    : IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = "");
                  },
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F5FF),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                  const BorderSide(color: Color(0xFFE6DEFF)),
                ),
              ),
            ),
          ),

          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("No students"))
                : ListView.separated(
              controller: _scrollCtrl,
              padding:
              const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount:
              list.length + (_loadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (_loadingMore && i == list.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                        child: CircularProgressIndicator()),
                  );
                }
                final s = list[i];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text("ID: ${s.id}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
