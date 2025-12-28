import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class AuthService {
  // Save login
  static Future<bool> login(String email, String password, String role) async {
    if (User.checkLogin(email, password, role)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_role', role);
      await prefs.setBool('is_logged_in', true);
      return true;
    }
    return false;
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }
}
