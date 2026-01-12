class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String grp; // ✅ Renommé de 'group' en 'grp' pour correspondre à la BD
  final String? year; // ✅ Ajouté le champ year
  final String? apiKey; // Pour les teachers

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'active', // ✅ Valeur par défaut
    this.grp = '', // ✅ Valeur par défaut
    this.year, // ✅ Optionnel
    this.apiKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      grp: (json['grp'] ?? json['group'] ?? '').toString(),
      year: json['year']?.toString(), // ✅ Récupère year depuis JSON
      apiKey: json['api_key']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'status': status,
    'grp': grp, // ✅ Utilise 'grp' au lieu de 'group'
    'year': year, // ✅ Inclut year dans le JSON
    'api_key': apiKey,
  };
}
