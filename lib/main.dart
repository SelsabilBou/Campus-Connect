import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'admin_panal.dart';
import 'auth_service.dart';
import 'register_screen.dart'; // NEW

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logged = await AuthService.isLoggedIn();
  final role = await AuthService.getUserRole();

  String initial;
  if (!logged) {
    initial = '/register'; // ✅ هنا يروح للـ Sign Up
  } else if (role == 'Admin') {
    initial = '/admin';
  } else {
    initial = '/home';
  }

  runApp(MyApp(initialRoute: initial));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const AuthScreen(),
        '/register': (_) => const RegisterScreen(), // ✅ route تاع sign up
        '/home': (_) => const HomeScreen(),
        '/admin': (_) => const AdminPanel(),
      },
    );
  }
}
