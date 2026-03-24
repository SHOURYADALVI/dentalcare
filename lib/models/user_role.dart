/// Enum for user roles in the dental clinic system
enum UserRole {
  patient('Patient'),
  dentist('Dentist'),
  receptionist('Receptionist');

  final String displayName;

  const UserRole(this.displayName);
}
