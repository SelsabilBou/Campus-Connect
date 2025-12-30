import 'package:flutter/material.dart';
import 'auth_service.dart';  // 👈 ADD THIS!
import 'user_model.dart';
import 'admin_panal.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  _loadUserRole() async {
    final role = await AuthService.getUserRole();
    if (mounted) setState(() => userRole = role);  // 👈 mounted check
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4B2E83);

    return Scaffold(
      backgroundColor: const Color(0xFF8E7CFF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Campus Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(child: _buildDashboard(userRole)),
    );
  }

  Widget _buildDashboard(String? role) {
    if (role == null) return const CircularProgressIndicator();

    switch (role) {
      case 'Admin':
        return buildRoleCard('Admin Dashboard', Icons.admin_panel_settings, ['Manage students', 'Approve registrations', 'View analytics'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPanel()),
            );
          },);
      case 'Teacher':
        return buildRoleCard('Teacher Dashboard', Icons.school, ['View classes', 'Manage attendance', 'Grade students']);
      case 'Student':
        return buildRoleCard('Student Dashboard', Icons.card_membership, ['View profile', 'Upcoming events', 'Academic schedule']);
      default:
        return const CircularProgressIndicator();
    }
  }

  Widget buildRoleCard(
      String title,
      IconData icon,
      List<String> features, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: const Color(0xFF4B2E83)),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(f, style: const TextStyle(fontSize: 16)),
              )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onTap,
                child: const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
