import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class AuthService {
  static const _userKey = 'logged_user';
  static const String baseUrl = 'http://10.0.2.2/compuse_app';

  static Future<bool> login(String email, String password, String role) async {
    try {
      final uri = Uri.parse('$baseUrl/login.php');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      if (data['success'] != true || data['user'] == null) return false;

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_role', user.role);
      await prefs.setBool('is_logged_in', true);

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> registerStudent(Map<String, String> data) async {
    try {
      final uri = Uri.parse('$baseUrl/register.php');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) return false;

      final result = jsonDecode(response.body);
      return result['success'] == true;
    } catch (_) {
      return false;
    }
  }

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
    await prefs.remove(_userKey);
  }

  static Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr == null) return null;
    return UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  // -------- Phase 5 helpers --------
  static Future<int?> getTeacherId() async {
    final u = await getLoggedInUser();
    if (u == null) return null;
    if (u.role.toLowerCase() != 'teacher') return null;
    return u.id;
  }

  static Future<String?> getTeacherApiKey() async {
    final u = await getLoggedInUser();
    if (u == null) return null;
    if (u.role.toLowerCase() != 'teacher') return null;
    return u.apiKey;
  }
}
