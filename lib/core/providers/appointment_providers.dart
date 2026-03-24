import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';

// Appointment service provider
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

/// All appointments list
final appointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getAllAppointments();
});

/// Get appointments by patient ID
final getPatientAppointmentsProvider =
    FutureProvider.family<List<Appointment>, String>((ref, patientId) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getAppointmentsByPatient(patientId);
});

/// Get appointments for a specific date
final getAppointmentsByDateProvider =
    FutureProvider.family<List<Appointment>, DateTime>((ref, date) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getAppointmentsByDate(date);
});

/// Get today's appointments
final todayAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getTodayAppointments();
});

/// Get available time slots for a date
final availableSlotsProvider =
    FutureProvider.family<List<DateTime>, DateTime>((ref, date) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getAvailableSlots(date);
});

/// Add appointment
final addAppointmentProvider =
    FutureProvider.family<Appointment, Appointment>((ref, appointment) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  final newAppointment = await appointmentService.addAppointment(appointment);
  // Invalidate related providers
  ref.invalidate(appointmentsProvider);
  ref.invalidate(todayAppointmentsProvider);
  return newAppointment;
});

/// Update appointment
final updateAppointmentProvider = FutureProvider.family<Appointment, Appointment>(
    (ref, appointment) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  final updatedAppointment =
      await appointmentService.updateAppointment(appointment);
  // Invalidate related providers
  ref.invalidate(appointmentsProvider);
  ref.invalidate(todayAppointmentsProvider);
  return updatedAppointment;
});

/// Delete appointment
final deleteAppointmentProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  await appointmentService.deleteAppointment(id);
  // Invalidate related providers
  ref.invalidate(appointmentsProvider);
  ref.invalidate(todayAppointmentsProvider);
});

/// Get today's appointment count
final todayAppointmentCountProvider = FutureProvider<int>((ref) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getTodayAppointmentCount();
});

/// Selected date for calendar
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
