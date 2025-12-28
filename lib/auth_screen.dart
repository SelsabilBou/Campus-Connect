import 'package:flutter/material.dart';
import 'auth_service.dart';  // 👈 ADD
import 'user_model.dart';    // 👈 ADD

class AuthScreen extends StatefulWidget {  // 👈 Stateful!
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole = 'Admin';  // Default Admin

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF8E7CFF);
    const Color cardColor = Colors.white;
    const Color primaryColor = Color(0xFF4B2E83);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back arrow (unchanged)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),

                // 👈 FIXED: Add controller!
                TextFormField(
                  controller: emailController,  // 👈 ADD THIS
                  decoration: InputDecoration(
                    labelText: 'Username or Email',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 16),

                // 👈 FIXED: Add controller!
                TextFormField(
                  controller: passwordController,  // 👈 ADD THIS
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 16),

                // 👈 Role dropdown (simple)
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                    DropdownMenuItem(value: 'Student', child: Text('Student')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value),
                ),
                const SizedBox(height: 8),

                // 👈 FIXED LOGIN BUTTON (NO duplicate child!)
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {  // 👈 LOGIN LOGIC!
                      bool success = await AuthService.login(
                        emailController.text,
                        passwordController.text,
                        selectedRole!,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login OK! 🎉')),
                        );

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ Wrong! Try: admin@campus.com / 123456')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(  // 👈 ONE child only!
                      'LOGIN',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Rest unchanged...
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Don't have an account? ", style: TextStyle(fontSize: 13)),
                    Text('Sign Up', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('OR', style: TextStyle(fontSize: 12))), Expanded(child: Divider())]),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _SocialCircle(color: const Color(0xFF4267B2), icon: Icons.facebook),
                  const SizedBox(width: 16),
                  _SocialCircle(color: const Color(0xFFDB4437), icon: Icons.g_mobiledata),
                  const SizedBox(width: 16),
                  _SocialCircle(color: const Color(0xFF1DA1F2), icon: Icons.mail_outline),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SocialCircle unchanged
class _SocialCircle extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _SocialCircle({required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 18, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 18));
  }
}
