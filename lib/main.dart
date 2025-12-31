import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import 'admin_panal.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';
import 'auth_service.dart';
import 'student_portal.dart';

// Instance globale du plugin de notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des notifications locales (Android)
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Écran de départ (welcome -> login -> home)
      initialRoute: 'welcome',
      routes: {
        'welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const AuthScreen(),
        '/register': (_) => const RegisterScreen(),

        // Home décide Admin vs Student selon le rôle
        '/home': (_) => const HomeScreen(),

        // Panneaux protégés par le rôle
        '/admin': (_) => const AdminPanel(),
        '/student': (_) => const StudentPortalScreen(),
      },
    );
  }
}

/// Écran de redirection après login.
/// Vérifie le rôle et envoie vers le bon panneau.
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
