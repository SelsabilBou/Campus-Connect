import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class AuthService {
  static const String baseUrl = 'http://localhost/compuse_app';  // 👈 YOUR URL!

  // 👈 REAL LOGIN API
  static Future<bool> login(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );
//here
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
          await prefs.setString('user_role', role);
          await prefs.setBool('is_logged_in', true);
          print('✅ REAL LOGIN: $email ($role)');
          return true;
        }
      }
    } catch (e) {
      print('❌ API Error: $e');
    }
    return false;
  }

  // 👈 REAL REGISTER API
  static Future<bool> registerStudent(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final result = jsonDecode(response.body);
      print('✅ REGISTER: ${result['message']}');
      return result['success'] ?? false;
    } catch (e) {
      print('❌ Register Error: $e');
      return false;
    }
  }

  // 👈 SharedPreferences (unchanged)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }
}
