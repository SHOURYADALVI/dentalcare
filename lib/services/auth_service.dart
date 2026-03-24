import '../models/user.dart';
import '../models/user_role.dart';

/// Mock authentication service for the dental clinic app
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? _currentUser;

  late final Map<String, User> _mockUsers = {
    'aarya@dental.com': User(
      id: '1',
      name: 'Aarya Patil',
      email: 'aarya@dental.com',
      role: UserRole.patient,
      phone: '+91 9876543210',
      createdAt: DateTime(2023, 1, 1),
    ),
    'rohit@dental.com': User(
      id: '2',
      name: 'Rohit Singh',
      email: 'rohit@dental.com',
      role: UserRole.patient,
      phone: '+91 9123456780',
      createdAt: DateTime(2023, 1, 1),
    ),
    'sneha@dental.com': User(
      id: '3',
      name: 'Sneha Iyer',
      email: 'sneha@dental.com',
      role: UserRole.patient,
      phone: '+91 9988776655',
      createdAt: DateTime(2023, 1, 1),
    ),
    'amit@dental.com': User(
      id: '4',
      name: 'Amit Verma',
      email: 'amit@dental.com',
      role: UserRole.patient,
      phone: '+91 9012345678',
      createdAt: DateTime(2023, 1, 1),
    ),
    'dentist@dental.com': User(
      id: 'dentist-001',
      name: 'Dr. Priya Sharma',
      email: 'dentist@dental.com',
      role: UserRole.dentist,
      phone: '+91 9823456789',
      createdAt: DateTime(2023, 1, 1),
    ),
    'receptionist@dental.com': User(
      id: 'receptionist-001',
      name: 'Sarah Johnson',
      email: 'receptionist@dental.com',
      role: UserRole.receptionist,
      phone: '+1-234-567-8902',
      createdAt: DateTime(2023, 1, 1),
    ),
  };

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  List<User> get demoPatientUsers {
    return _mockUsers.values
        .where((user) => user.role == UserRole.patient)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Simulate login with mock data
  /// Returns true if login is successful
  Future<bool> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simple mock validation (any password works for demo)
    final normalizedEmail = email.trim().toLowerCase();
    if (_mockUsers.containsKey(normalizedEmail)) {
      _currentUser = _mockUsers[normalizedEmail];
      return true;
    }

    return false;
  }

  /// Simulate logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<UserRole> roles) {
    return _currentUser != null && roles.contains(_currentUser!.role);
  }
}
