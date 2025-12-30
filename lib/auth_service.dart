import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class AuthService {
  static const _userKey = 'logged_user';
  static const String baseUrl = 'http://10.0.2.2/compuse_app';

  // LOGIN API
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

      print('LOGIN URL=$uri');
      print('LOGIN STATUS=${response.statusCode}');
      print('LOGIN BODY=${response.body}');

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);

      // On attend un JSON du style:
      // { "success": true, "user": { "id":1, "name":"...", "email":"...", "role":"student", "group":"L2-G3" } }
      final bool success = data['success'] == true;
      if (!success) return false;

      if (data['user'] == null) {
        // Pas d'objet user → on ne peut pas remplir le profil
        return false;
      }

      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      final prefs = await SharedPreferences.getInstance();
      // On garde l'objet complet pour le profil + autres onglets
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      // Optionnel: garder aussi email/role/flag
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_role', user.role);
      await prefs.setBool('is_logged_in', true);

      print('✅ REAL LOGIN: ${user.email} (${user.role})');
      return true;
    } catch (e) {
      print('❌ API Error: $e');
      return false;
    }
  }

  // REGISTER API
  static Future<bool> registerStudent(Map<String, String> data) async {
    try {
      final uri = Uri.parse('$baseUrl/register.php');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('REGISTER STATUS=${response.statusCode}');
      print('REGISTER BODY=${response.body}');

      if (response.statusCode != 200) return false;

      final result = jsonDecode(response.body);
      print('✅ REGISTER: ${result['message']}');
      return result['success'] == true;
    } catch (e) {
      print('❌ Register Error: $e');
      return false;
    }
  }

  // SharedPreferences helpers
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
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }
}
