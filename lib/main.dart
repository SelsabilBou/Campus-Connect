import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'student_portal.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'admin.dart';
import 'register_screen.dart';
import 'welcome_screen.dart'; // <— importe ta page welcome
import 'teacher_dashboard.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // première page = WelcomeScreen
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const AuthScreen(),
        '/student': (context) => const StudentPortalScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/admin': (_) => const AdminPanel(),
        '/teacher': (_) => const TeacherDashboard(),
      },
    );
  }
}
