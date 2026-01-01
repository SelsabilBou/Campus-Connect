class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String group; // grp de la BD, peut être vide

  // Phase 5 (Teacher auth)
  final String? apiKey; // <-- ADD (teacher only)

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.group,
    this.apiKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      group: (json['grp'] ?? json['group'] ?? '').toString(),

      // Phase 5
      apiKey: json['api_key']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'status': status,
    'group': group,

    // Phase 5
    'api_key': apiKey,
  };
}
