import '../models/appointment.dart';

/// Mock appointment data repository service
class AppointmentService {
  static final AppointmentService _instance =
      AppointmentService._internal();

  factory AppointmentService() {
    return _instance;
  }

  AppointmentService._internal();

  // In-memory storage for mock data
  final List<Appointment> _appointments = [
    Appointment(
      id: 'apt-001',
      patientId: 'patient-001',
      patientName: 'John Doe',
      appointmentDate: DateTime.now(),
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      dentistName: 'Dr. John Smith',
      status: AppointmentStatus.scheduled,
      notes: 'Regular checkup',
    ),
    Appointment(
      id: 'apt-002',
      patientId: 'patient-002',
      patientName: 'Jane Smith',
      appointmentDate: DateTime.now().add(const Duration(days: 1)),
      startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      dentistName: 'Dr. John Smith',
      status: AppointmentStatus.scheduled,
      notes: 'Cavity filling',
    ),
  ];

  /// Get all appointments
  Future<List<Appointment>> getAllAppointments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _appointments;
  }

  /// Get appointments by patient ID
  Future<List<Appointment>> getAppointmentsByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _appointments
        .where((apt) => apt.patientId == patientId)
        .toList();
  }

  /// Get appointments for a specific date
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _appointments
        .where((apt) =>
            apt.appointmentDate.year == date.year &&
            apt.appointmentDate.month == date.month &&
            apt.appointmentDate.day == date.day)
        .toList();
  }

  /// Get today's appointments
  Future<List<Appointment>> getTodayAppointments() async {
    final today = DateTime.now();
    return getAppointmentsByDate(today);
  }

  /// Check if time slot is available
  Future<bool> isTimeSlotAvailable(
    DateTime date,
    DateTime startTime,
    DateTime endTime,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final appointments = await getAppointmentsByDate(date);
    for (var apt in appointments) {
      if (!(endTime.isBefore(apt.startTime) ||
          startTime.isAfter(apt.endTime))) {
        return false;
      }
    }
    return true;
  }

  /// Get available time slots for a date
  Future<List<DateTime>> getAvailableSlots(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    const workingHours = 8; // 9 AM to 5 PM
    const slotDuration = 60; // 1 hour slots
    final slots = <DateTime>[];

    for (var hour = 9; hour < 17; hour++) {
      final slotStart = DateTime(date.year, date.month, date.day, hour);
      final slotEnd = slotStart.add(const Duration(minutes: slotDuration));

      final isAvailable = await isTimeSlotAvailable(date, slotStart, slotEnd);
      if (isAvailable) {
        slots.add(slotStart);
      }
    }

    return slots;
  }

  /// Add new appointment
  Future<Appointment> addAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _appointments.add(appointment);
    return appointment;
  }

  /// Update appointment
  Future<Appointment> updateAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _appointments.indexWhere((apt) => apt.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      return _appointments[index];
    }
    throw Exception('Appointment not found');
  }

  /// Delete appointment
  Future<void> deleteAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _appointments.removeWhere((apt) => apt.id == id);
  }

  /// Get today's appointment count
  Future<int> getTodayAppointmentCount() async {
    final today = await getTodayAppointments();
    return today.length;
  }
}
