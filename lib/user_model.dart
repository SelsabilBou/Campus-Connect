class User {
  final String name;
  final String email;
  final String role;

  User({required this.name, required this.email, required this.role});

  // Test accounts (all password = 123456)
  static List<User> testAccounts = [
    User(name: 'Admin', email: 'admin@campus.com', role: 'Admin'),
    User(name: 'Ahmed', email: 'ahmed@campus.com', role: 'Teacher'),
    User(name: 'Fatima', email: 'fatima@campus.com', role: 'Teacher'),
    User(name: 'Selsabil', email: 'selsabil@campus.com', role: 'Student'),
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
