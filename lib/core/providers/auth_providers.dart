import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import './clinic_crud_providers.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final demoPatientUsersProvider = Provider<List<User>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final patients = ref.watch(patientListProvider);
  
  // Get all patients as User objects
  final patientUsers = patients
      .where((patient) => patient.email != null && patient.email!.isNotEmpty)
      .map((patient) => User(
        id: patient.id,
        name: patient.name,
        email: patient.email!,
        role: UserRole.patient,
        phone: patient.phone,
        createdAt: patient.createdAt,
      ))
      .toList();
  
  // Combine with any hardcoded patient users from auth service
  final allPatientEmails = <String>{};
  final combinedUsers = <User>[];
  
  // Add dynamic patient users first
  for (final user in patientUsers) {
    allPatientEmails.add(user.email);
    combinedUsers.add(user);
  }
  
  // Add hardcoded patient users that aren't already in the list
  for (final user in authService.demoPatientUsers) {
    if (!allPatientEmails.contains(user.email)) {
      combinedUsers.add(user);
    }
  }
  
  // Sort by name
  combinedUsers.sort((a, b) => a.name.compareTo(b.name));
  
  return combinedUsers;
});

/// Current authenticated user
final currentUserProvider = StateProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// Login state handling
final loginProvider = FutureProvider.family<bool, (String, String)>((ref, credentials) async {
  final authService = ref.watch(authServiceProvider);
  final patients = ref.watch(patientListProvider);
  final (email, password) = credentials;
  
  // First try hardcoded users (dentist, receptionist, hardcoded patients)
  final result = await authService.login(email, password);
  if (result) {
    ref.read(currentUserProvider.notifier).state = authService.currentUser;
    return true;
  }
  
  // If not a hardcoded user, check if they're a patient with a valid email
  final normalizedEmail = email.trim().toLowerCase();
  final matchingPatient = patients.firstWhere(
    (p) => p.email != null && p.email!.toLowerCase() == normalizedEmail,
    orElse: () => null as dynamic,
  );
  
  if (matchingPatient != null) {
    // Create a User object for this patient
    final patientUser = User(
      id: matchingPatient.id,
      name: matchingPatient.name,
      email: matchingPatient.email!,
      role: UserRole.patient,
      phone: matchingPatient.phone,
      createdAt: matchingPatient.createdAt,
    );
    ref.read(currentUserProvider.notifier).state = patientUser;
    return true;
  }
  
  return false;
});

/// Logout handler
final logoutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.logout();
  ref.read(currentUserProvider.notifier).state = null;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Get current user role
final currentUserRoleProvider = Provider((ref) {
  return ref.watch(currentUserProvider)?.role;
});
