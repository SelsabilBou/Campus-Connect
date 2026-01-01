import 'package:flutter/material.dart';
import 'auth_service.dart';

/// Écran de redirection après login.
/// Vérifie le rôle (Admin / Student) puis envoie vers la bonne route.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final user = await AuthService.getLoggedInUser();
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else if (user.role == 'Student') {
      Navigator.pushReplacementNamed(context, '/student');
    } else if (user.role == 'Admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (user.role == 'Teacher') {
      Navigator.pushReplacementNamed(context, '/teacher');  // 👈 NEW
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
