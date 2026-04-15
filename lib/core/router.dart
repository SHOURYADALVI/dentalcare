import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../core/providers/auth_providers.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/patients/presentation/pages/patients_list_page.dart';
import '../features/patients/presentation/pages/patient_detail_page.dart';
import '../features/patients/presentation/pages/add_edit_patient_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/appointments/presentation/pages/appointments_page.dart';
import '../features/treatments/presentation/pages/treatments_page.dart';
import '../features/billing/presentation/pages/billing_page.dart';
import '../features/patient_portal/presentation/pages/patient_dashboard_page.dart';
import '../features/patient_portal/presentation/pages/patient_appointments_page.dart';
import '../features/patient_portal/presentation/pages/patient_payment_page.dart';
import '../features/patient_portal/presentation/pages/patient_report_page.dart';
import '../features/patient_portal/presentation/pages/doctor_info_page.dart';
import '../features/doctor/presentation/pages/doctor_dashboard_screen.dart';

/// Router configuration for the dental clinic app
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUserRole = ref.watch(currentUserRoleProvider);

  return GoRouter(
    initialLocation: isAuthenticated ? '/dashboard' : '/login',
    redirect: (context, state) {
      // Redirect logic based on authentication
      final isLoggingIn = state.matchedLocation == '/login';
      if (!isAuthenticated) {
        if (isLoggingIn) return null;
        return '/login';
      }

      // Redirect from login to dashboard if already authenticated
      if (isLoggingIn) return '/dashboard';

      // Role-based route access
      if (state.matchedLocation == '/dashboard' &&
          currentUserRole == UserRole.receptionist) {
        return '/receptionist';
      }

      if (state.matchedLocation == '/dashboard' &&
          currentUserRole == UserRole.patient) {
        return '/patient';
      }

      if (state.matchedLocation == '/dashboard' &&
          currentUserRole == UserRole.dentist) {
        return '/doctor';
      }

      return null;
    },
    routes: [
      // Authentication route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Dashboard route (accessible to all authenticated users)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Patient portal routes
      GoRoute(
        path: '/patient',
        name: 'patient-dashboard',
        builder: (context, state) => const PatientDashboardPage(),
      ),
      GoRoute(
        path: '/patient/appointments',
        name: 'patient-appointments',
        builder: (context, state) => const PatientAppointmentsPage(),
      ),
      GoRoute(
        path: '/patient/payments',
        name: 'patient-payments',
        builder: (context, state) => const PatientPaymentPage(),
      ),
      GoRoute(
        path: '/patient/report',
        name: 'patient-report',
        builder: (context, state) => const PatientReportPage(),
      ),
      GoRoute(
        path: '/patient/doctor-info',
        name: 'patient-doctor-info',
        builder: (context, state) => const DoctorInfoPage(),
      ),

      // Doctor dashboard route
      GoRoute(
        path: '/doctor',
        name: 'doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),

      // Receptionist portal route with same appointments/report capabilities
      GoRoute(
        path: '/receptionist',
        name: 'receptionist-dashboard',
        builder: (context, state) =>
            const DoctorDashboardScreen(portalTitle: 'DENTLINK Receptionist Dashboard'),
      ),

      // Patient management routes
      GoRoute(
        path: '/patients',
        name: 'patients',
        builder: (context, state) => const PatientsListPage(),
        routes: [
          GoRoute(
            path: 'detail/:patientId',
            name: 'patient-detail',
            builder: (context, state) {
              final patientId = state.pathParameters['patientId']!;
              return PatientDetailPage(patientId: patientId);
            },
          ),
          GoRoute(
            path: 'add',
            name: 'add-patient',
            builder: (context, state) => const AddEditPatientPage(),
          ),
          GoRoute(
            path: 'edit/:patientId',
            name: 'edit-patient',
            builder: (context, state) {
              final patientId = state.pathParameters['patientId']!;
              return AddEditPatientPage(patientId: patientId);
            },
          ),
        ],
      ),

      // Appointments route
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const AppointmentsPage(),
      ),

      // Treatments route
      GoRoute(
        path: '/treatments',
        name: 'treatments',
        builder: (context, state) => const TreatmentsPage(),
      ),

      // Billing route
      GoRoute(
        path: '/billing',
        name: 'billing',
        builder: (context, state) => const BillingPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
