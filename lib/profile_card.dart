import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String fullName;
  final String studentId;
  final String group;
  final String email;

  const ProfileCard({
    super.key,
    required this.fullName,
    required this.studentId,
    required this.group,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Colors.white;
    const Color primaryColor = Color(0xFF8E7CFF); // violet
    const Color accentColor = Color(0xFF4B2E83);  // violet clair

    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar + nom
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accentColor,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Infos
            _InfoRow(label: 'Student ID', value: studentId),
            const SizedBox(height: 8),
            _InfoRow(label: 'Group', value: group),
            const SizedBox(height: 8),
            _InfoRow(label: 'Email', value: email),

            const SizedBox(height: 16),

            // Bouton Edit (plus tard pour modification)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // plus tard: ouvrir écran d’édition
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
