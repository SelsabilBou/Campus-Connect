import 'package:flutter/material.dart';
import 'profile_card.dart';
import 'auth_service.dart';
import 'user_model.dart';  // 👈 ADD THIS!

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers unchanged...
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController matriculeController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController adminCodeController = TextEditingController();

  String? selectedRole;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    groupController.dispose();
    yearController.dispose();
    matriculeController.dispose();
    specialtyController.dispose();
    departmentController.dispose();
    adminCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF8E7CFF);
    const Color cardColor = Colors.white;
    const Color primaryColor = Color(0xFF4B2E83);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ProfileCard (unchanged - perfect!)
                  if (selectedRole == 'Student') ...[
                    const Text(
                      'Preview Card:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ProfileCard(
                      fullName: fullNameController.text.isEmpty ? "Selsabil" : fullNameController.text,
                      studentId: matriculeController.text.isEmpty ? "1234" : matriculeController.text,
                      group: groupController.text.isEmpty ? "2" : groupController.text,
                      email: emailController.text.isEmpty ? "selsabil@exemple.com" : emailController.text,
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text('Sign Up', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // All TextFields unchanged...
                  TextField(controller: fullNameController, decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(labelText: 'Role', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: const [
                      DropdownMenuItem(value: 'Student', child: Text('Student')),
                      DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    ],
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                  const SizedBox(height: 12),

                  // Role fields unchanged...
                  if (selectedRole == 'Student') ...[
                    TextField(controller: groupController, decoration: InputDecoration(labelText: 'Group', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: yearController, decoration: InputDecoration(labelText: 'Year', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: matriculeController, decoration: InputDecoration(labelText: 'Matricule', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                  ] else if (selectedRole == 'Teacher') ...[
                    TextField(controller: specialtyController, decoration: InputDecoration(labelText: 'Specialty', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: departmentController, decoration: InputDecoration(labelText: 'Department', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                  ] else if (selectedRole == 'Admin') ...[
                    TextField(controller: adminCodeController, decoration: InputDecoration(labelText: 'Admin Code (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 8),

                  // 👈 FIXED REGISTER BUTTON!
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedRole == 'Student' ? () async {  // Only students!
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registering... ⏳')));

                        bool success = await AuthService.registerStudent({
                          'name': fullNameController.text,
                          'email': emailController.text,
                          'group': groupController.text,
                          'matricule': matriculeController.text,
                        });

                        if (success) {
                          // 👈 ADD ADMIN APPROVAL HERE!
                          await Future.delayed(Duration(seconds: 2)); // Fake admin check
                          final newStudent = User(
                            name: fullNameController.text,
                            email: emailController.text,
                            role: 'Student',
                            status: 'approved', // Admin approved!
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Student registered! (Auto-approved)'), backgroundColor: Colors.green),
                          );
                          debugPrint('🎉 REGISTERED & APPROVED: ${fullNameController.text} → ${emailController.text}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Registration failed')));
                        }
                      } : null,  // Disable for non-students
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
