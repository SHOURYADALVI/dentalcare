import 'user_role.dart';

/// User model represents a system user (Patient, Dentist, Receptionist)
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.isActive = true,
    required this.createdAt,
  });

  /// Create a copy of user with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: ${role.displayName})';
  }
}
