import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'admin_panal.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 👇 Always start here
      initialRoute: 'welcome',
      routes: {
        'welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const AuthScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/admin': (_) => const AdminPanel(),
      },
    );
  }
}
