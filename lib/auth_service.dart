import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class AuthService {
  // 👈 FAKE DATABASE (like real MySQL)
  static List<User> fakeDatabase = [
    User(name: 'Admin', email: 'admin@campus.com', role: 'Admin', status: 'approved'),
    User(name: 'Ahmed', email: 'ahmed@campus.com', role: 'Teacher', status: 'approved'),
    User(name: 'Fatima', email: 'fatima@campus.com', role: 'Teacher', status: 'approved'),
  ];

  // 👈 REGISTER STUDENT (fake API)
  static Future<bool> registerStudent(Map<String, String> data) async {
    await Future.delayed(Duration(seconds: 1)); // Fake network

    final newStudent = User(
      name: data['name']!,
      email: data['email']!,
      role: 'Student',
      status: 'approved',  // Waits admin approval
    );

    fakeDatabase.add(newStudent);
    print('✅ NEW STUDENT Approved: ${data['name']} (${data['email']})');
    return true;
  }

  // 👈 LOGIN (check fake DB)
  static Future<bool> login(String email, String password, String role) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('🔍 TRY LOGIN: $email / $role');
    try {
      final user = fakeDatabase.firstWhere(
              (u) => u.email == email && u.role == role && u.status == 'approved'
      );
      print('✅ MATCH FOUND: ${user.name} (${user.role})');  // 👈 DEBUG
      if (password == '123456') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', role);
        await prefs.setBool('is_logged_in', true);
        print('🎉 LOGIN SUCCESS: $email');
        return true;
      }
    } catch (e) {
      print('❌ NO MATCH FOR: $email / $role → $e');  // 👈 DEBUG
    }
    print('❌ LOGIN FAILED');
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
  // 👈 ADD THIS!
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

}
