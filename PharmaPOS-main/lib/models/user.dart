enum UserRole {
  admin,
  pharmacist,
  seller;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.seller;
    
    final normalized = role.toLowerCase().trim();
    
    if (normalized.contains('admin')) {
      return UserRole.admin;
    } else if (normalized.contains('pharma')) {
      return UserRole.pharmacist;
    } else if (normalized.contains('cais') || normalized.contains('vend') || normalized.contains('sell')) {
      return UserRole.seller;
    }
    
    return UserRole.seller; // Par défaut, rôle le plus restreint
  }

  String toJson() => name;
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.fromString(json['role'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toJson(),
    };
  }
}
