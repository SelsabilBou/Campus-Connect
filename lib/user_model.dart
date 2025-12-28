class User {
  final String name;
  final String email;
  final String role;
  final String status;

  User({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  // Test accounts (all approved)
  static List<User> testAccounts = [
    User(name: 'Admin', email: 'admin@campus.com', role: 'Admin', status: 'approved'),
    User(name: 'Ahmed', email: 'ahmed@campus.com', role: 'Teacher', status: 'approved'),
    User(name: 'Fatima', email: 'fatima@campus.com', role: 'Teacher', status: 'approved'),
    User(name: 'Selsabil', email: 'selsabil@campus.com', role: 'Student', status: 'approved'),
  ];

  static bool checkLogin(String email, String password, String role) {
    try {
      final user = testAccounts.firstWhere((u) => u.email == email && u.role == role);
      return password == '123456';
    } catch (e) {
      return false;
    }
  }
}
