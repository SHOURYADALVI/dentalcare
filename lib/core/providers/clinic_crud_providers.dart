import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/appointment.dart';
import '../../models/doctor_profile.dart';
import '../../models/doctor_report.dart';
import '../../models/patient.dart';
import '../../models/payment_summary.dart';
import '../../services/local_store/local_store.dart';

const _doctorStorageKey = 'dentlink_doctor_profile';
const _patientsStorageKey = 'dentlink_patient_list';
const _appointmentsStorageKey = 'dentlink_appointments';
const _availabilityStorageKey = 'dentlink_availability';
const _reportsStorageKey = 'dentlink_reports';
const _paymentsStorageKey = 'dentlink_payments';
final _store = createLocalStore();

class ClinicAvailability {
  final int startHour;
  final int endHour;

  const ClinicAvailability({
    required this.startHour,
    required this.endHour,
  });

  ClinicAvailability copyWith({
    int? startHour,
    int? endHour,
  }) {
    return ClinicAvailability(
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  factory ClinicAvailability.fromJson(Map<String, dynamic> json) {
    return ClinicAvailability(
      startHour: (json['startHour'] ?? 9) as int,
      endHour: (json['endHour'] ?? 17) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startHour': startHour,
      'endHour': endHour,
    };
  }
}

class DoctorNotifier extends StateNotifier<DoctorProfile> {
  DoctorNotifier()
      : super(
          const DoctorProfile(
            id: 'doctor-001',
            name: 'Dr. Priya Sharma',
            qualification: 'BDS, MDS (Endodontist)',
            specialization: 'Dentist',
            phone: '+91 9823456789',
            email: 'dr.priya@smileclinic.in',
            clinicAddress: 'Smile Care Dental Clinic, Andheri, Mumbai',
            avatarAsset: null,
          ),
        ) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _store.getString(_doctorStorageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    state = DoctorProfile.fromJson(decoded);
  }

  Future<void> updateProfile(DoctorProfile updated) async {
    state = updated;
    await _store.setString(_doctorStorageKey, jsonEncode(updated.toJson()));
  }
}

class PatientListNotifier extends StateNotifier<List<Patient>> {
  PatientListNotifier()
      : super([
          Patient(
            id: '1',
            name: 'Aarya Patil',
            phone: '+91 9876543210',
            age: 24,
            gender: 'Female',
            medicalHistory: 'Tooth Pain (Cavity)',
            totalAmount: 1500,
            paidAmount: 500,
            email: 'aarya@smileclinic.in',
            address: 'Mumbai',
          ),
          Patient(
            id: '2',
            name: 'Rohit Singh',
            phone: '+91 9123456780',
            age: 32,
            gender: 'Male',
            medicalHistory: 'Root Canal',
            totalAmount: 6000,
            paidAmount: 2000,
            email: 'rohit@smileclinic.in',
            address: 'Mumbai',
          ),
          Patient(
            id: '3',
            name: 'Sneha Iyer',
            phone: '+91 9988776655',
            age: 28,
            gender: 'Female',
            medicalHistory: 'Teeth Cleaning',
            totalAmount: 1200,
            paidAmount: 1200,
            email: 'sneha@smileclinic.in',
            address: 'Mumbai',
          ),
          Patient(
            id: '4',
            name: 'Amit Verma',
            phone: '+91 9012345678',
            age: 40,
            gender: 'Male',
            medicalHistory: 'Tooth Extraction',
            totalAmount: 2500,
            paidAmount: 1000,
            email: 'amit@smileclinic.in',
            address: 'Mumbai',
          ),
        ]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _store.getString(_patientsStorageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded
        .map((item) => Patient.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persist() async {
    final encoded = state.map((p) => p.toJson()).toList();
    await _store.setString(_patientsStorageKey, jsonEncode(encoded));
  }

  Future<void> addPatient(Patient patient) async {
    final normalized = patient.copyWith(
      id: patient.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : patient.id,
      updatedAt: DateTime.now(),
    );
    state = [...state, normalized];
    await _persist();
  }

  Future<void> updatePatient(Patient patient) async {
    state = [
      for (final p in state)
        if (p.id == patient.id) patient.copyWith(updatedAt: DateTime.now()) else p,
    ];
    await _persist();
  }

  Future<void> deletePatient(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }
}

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  ClinicAvailability _availability = const ClinicAvailability(startHour: 9, endHour: 17);

  AppointmentNotifier()
      : super([
          Appointment(
            id: 'apt-001',
            patientId: '1',
            patientName: 'Aarya Patil',
            appointmentDate: DateTime.now(),
            startTime: DateTime.now().copyWith(hour: 10, minute: 0),
            endTime: DateTime.now().copyWith(hour: 11, minute: 0),
            dentistName: 'Dr. Priya Sharma',
            status: AppointmentStatus.scheduled,
            reasonForVisit: 'Tooth pain',
          ),
          Appointment(
            id: 'apt-002',
            patientId: '2',
            patientName: 'Rohit Singh',
            appointmentDate: DateTime.now(),
            startTime: DateTime.now().copyWith(hour: 11, minute: 30),
            endTime: DateTime.now().copyWith(hour: 12, minute: 30),
            dentistName: 'Dr. Priya Sharma',
            status: AppointmentStatus.completed,
            reasonForVisit: 'Root canal follow-up',
          ),
        ]) {
    _load();
  }

  ClinicAvailability get availability => _availability;

  Future<void> _load() async {
    final availabilityRaw = await _store.getString(_availabilityStorageKey);
    if (availabilityRaw != null && availabilityRaw.isNotEmpty) {
      _availability = ClinicAvailability.fromJson(
        jsonDecode(availabilityRaw) as Map<String, dynamic>,
      );
    }

    final raw = await _store.getString(_appointmentsStorageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
    await purgeExpiredCompletedAppointments();
  }

  Future<void> _persistAvailability() async {
    await _store.setString(_availabilityStorageKey, jsonEncode(_availability.toJson()));
  }

  Future<void> _persist() async {
    final encoded = state.map((a) => a.toJson()).toList();
    await _store.setString(_appointmentsStorageKey, jsonEncode(encoded));
  }

  bool _hasConflict(Appointment target) {
    for (final apt in state) {
      if (apt.id == target.id) continue;
      if (apt.status == AppointmentStatus.cancelled) continue;
      if (apt.status == AppointmentStatus.requested) continue;
      if (apt.appointmentDate.year != target.appointmentDate.year ||
          apt.appointmentDate.month != target.appointmentDate.month ||
          apt.appointmentDate.day != target.appointmentDate.day) {
        continue;
      }

      final overlap = !(target.endTime.isBefore(apt.startTime) ||
          target.startTime.isAfter(apt.endTime));
      if (overlap) return true;
    }
    return false;
  }

  DateTime _atHour(DateTime date, int hour) {
    return DateTime(date.year, date.month, date.day, hour);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> buildHourlySlotsForDate(DateTime date) {
    final normalized = _normalizeDate(date);
    final slots = <DateTime>[];
    for (var hour = _availability.startHour; hour < _availability.endHour; hour++) {
      slots.add(_atHour(normalized, hour));
    }
    return slots;
  }

  bool isSlotBooked(DateTime slotStart) {
    final slotEnd = slotStart.add(const Duration(hours: 1));
    return state.any((apt) {
      if (apt.status != AppointmentStatus.scheduled && apt.status != AppointmentStatus.completed) {
        return false;
      }
      if (!_isSameDay(apt.appointmentDate, slotStart)) return false;
      return !(slotEnd.isBefore(apt.startTime) || slotStart.isAfter(apt.endTime));
    });
  }

  bool isSlotPending(DateTime slotStart) {
    final slotEnd = slotStart.add(const Duration(hours: 1));
    return state.any((apt) {
      if (apt.status != AppointmentStatus.requested) return false;
      if (!_isSameDay(apt.appointmentDate, slotStart)) return false;

      final prefStart = apt.preferredStartTime;
      final prefEnd = apt.preferredEndTime;

      if (prefStart == null || prefEnd == null) {
        return apt.startTime.hour == slotStart.hour;
      }

      return !(slotEnd.isBefore(prefStart) || slotStart.isAfter(prefEnd));
    });
  }

  List<DateTime> getAvailableSlotsForDate(DateTime date) {
    final slots = buildHourlySlotsForDate(date);
    return slots.where((slot) => !isSlotBooked(slot)).toList();
  }

  List<Appointment> getPendingRequests() {
    final pending = state.where((apt) => apt.status == AppointmentStatus.requested).toList();
    pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return pending;
  }

  Future<void> updateWorkingHours({
    required int startHour,
    required int endHour,
  }) async {
    if (startHour < 0 || endHour > 24 || endHour <= startHour) {
      throw Exception('Invalid working hours');
    }

    _availability = ClinicAvailability(startHour: startHour, endHour: endHour);
    await _persistAvailability();
  }

  Future<void> requestAppointment({
    required String patientId,
    required String patientName,
    required DateTime preferredDate,
    DateTime? preferredStartTime,
    DateTime? preferredEndTime,
    required String reasonForVisit,
  }) async {
    await purgeExpiredCompletedAppointments();

    final baseStart = preferredStartTime ?? _atHour(preferredDate, _availability.startHour);
    final baseEnd = preferredEndTime ?? baseStart.add(const Duration(hours: 1));
    final normalizedDate = _normalizeDate(preferredDate);

    final duplicateIndex = state.indexWhere(
      (apt) =>
          apt.patientId == patientId &&
          apt.status == AppointmentStatus.requested &&
          apt.appointmentDate.year == normalizedDate.year &&
          apt.appointmentDate.month == normalizedDate.month &&
          apt.appointmentDate.day == normalizedDate.day &&
          apt.startTime == baseStart &&
          apt.endTime == baseEnd &&
          apt.reasonForVisit == reasonForVisit,
    );

    if (duplicateIndex != -1) {
      return;
    }

    final request = Appointment(
      patientId: patientId,
      patientName: patientName,
      appointmentDate: normalizedDate,
      startTime: baseStart,
      endTime: baseEnd,
      preferredStartTime: preferredStartTime,
      preferredEndTime: preferredEndTime,
      reasonForVisit: reasonForVisit,
      dentistName: 'Dr. Priya Sharma',
      status: AppointmentStatus.requested,
    );

    state = [...state, request];
    await _persist();
  }

  Future<void> approveRequest({
    required String requestId,
    required DateTime slotStart,
    required String dentistName,
  }) async {
    final request = state.firstWhere((a) => a.id == requestId);
    final approved = request.copyWith(
      appointmentDate: _normalizeDate(slotStart),
      startTime: slotStart,
      endTime: slotStart.add(const Duration(hours: 1)),
      status: AppointmentStatus.scheduled,
      dentistName: dentistName,
      rejectionReason: null,
    );

    if (_hasConflict(approved)) {
      throw Exception('Selected slot is already booked');
    }

    state = [
      for (final apt in state)
        if (apt.id == requestId) approved else apt,
    ];
    await _persist();
  }

  Future<void> rejectRequest({
    required String requestId,
    String? reason,
  }) async {
    state = [
      for (final apt in state)
        if (apt.id == requestId)
          apt.copyWith(
            status: AppointmentStatus.cancelled,
            rejectionReason: reason,
          )
        else
          apt,
    ];
    await _persist();
  }

  bool _isExpiredCompletedAppointment(Appointment appointment, DateTime now) {
    if (appointment.status != AppointmentStatus.completed) return false;
    final cutoff = now.subtract(const Duration(days: 2));
    return appointment.appointmentDate.isBefore(cutoff);
  }

  Future<void> purgeExpiredCompletedAppointments() async {
    final now = DateTime.now();
    final cleaned = state
        .where((a) => !_isExpiredCompletedAppointment(a, now))
        .toList();

    if (cleaned.length == state.length) {
      return;
    }

    state = cleaned;
    await _persist();
  }

  Future<void> addAppointment(Appointment appointment) async {
    await purgeExpiredCompletedAppointments();
    if (_hasConflict(appointment)) {
      throw Exception('Time slot already booked');
    }
    state = [...state, appointment];
    await _persist();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await purgeExpiredCompletedAppointments();
    if (_hasConflict(appointment)) {
      throw Exception('Time slot already booked');
    }
    state = [
      for (final apt in state)
        if (apt.id == appointment.id) appointment else apt,
    ];
    await _persist();
  }

  Future<void> deleteAppointment(String id) async {
    await purgeExpiredCompletedAppointments();
    state = state.where((a) => a.id != id).toList();
    await _persist();
  }
}

class ReportNotifier extends StateNotifier<List<DoctorReport>> {
  ReportNotifier()
      : super([
          DoctorReport(
            id: 'rep-001',
            patientId: '1',
            doctorId: 'doctor-001',
            diagnosis: 'Dental cavity in upper premolar',
            treatment: 'Composite filling and sensitivity management',
            medicines: 'Ibuprofen 400mg, Sensodyne toothpaste',
            precautions: 'Avoid very cold items for 3 days and brush softly',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _store.getString(_reportsStorageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded
        .map((item) => DoctorReport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persist() async {
    final encoded = state.map((r) => r.toJson()).toList();
    await _store.setString(_reportsStorageKey, jsonEncode(encoded));
  }

  Future<void> upsertReport(DoctorReport report) async {
    final index = state.indexWhere((r) => r.patientId == report.patientId);
    if (index == -1) {
      state = [...state, report];
      await _persist();
      return;
    }

    state = [
      for (final r in state)
        if (r.patientId == report.patientId) report else r,
    ];
    await _persist();
  }

  DoctorReport? reportForPatient(String patientId) {
    try {
      final entries = state.where((r) => r.patientId == patientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries.isEmpty ? null : entries.first;
    } catch (_) {
      return null;
    }
  }
}

class PaymentNotifier extends StateNotifier<List<PaymentSummary>> {
  PaymentNotifier()
      : super(const [
          PaymentSummary(patientId: '1', total: 1500, paid: 500),
          PaymentSummary(patientId: '2', total: 6000, paid: 2000),
          PaymentSummary(patientId: '3', total: 1200, paid: 1200),
          PaymentSummary(patientId: '4', total: 2500, paid: 1000),
        ]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _store.getString(_paymentsStorageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded
        .map((item) => PaymentSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persist() async {
    final encoded = state.map((p) => p.toJson()).toList();
    await _store.setString(_paymentsStorageKey, jsonEncode(encoded));
  }

  PaymentSummary byPatientId(String patientId) {
    return state.firstWhere(
      (p) => p.patientId == patientId,
      orElse: () => PaymentSummary(patientId: patientId, total: 0, paid: 0),
    );
  }

  Future<void> upsertPayment(PaymentSummary summary) async {
    if (summary.paid > summary.total) {
      throw Exception('Paid amount cannot be greater than total amount');
    }

    final idx = state.indexWhere((p) => p.patientId == summary.patientId);
    if (idx == -1) {
      state = [...state, summary];
      await _persist();
      return;
    }

    state = [
      for (final p in state)
        if (p.patientId == summary.patientId) summary else p,
    ];
    await _persist();
  }
}

final doctorProvider = StateNotifierProvider<DoctorNotifier, DoctorProfile>((ref) {
  return DoctorNotifier();
});

final patientListProvider = StateNotifierProvider<PatientListNotifier, List<Patient>>((ref) {
  return PatientListNotifier();
});

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier();
});

final clinicAvailabilityProvider = Provider<ClinicAvailability>((ref) {
  ref.watch(appointmentProvider);
  return ref.read(appointmentProvider.notifier).availability;
});

final appointmentRequestsProvider = Provider<List<Appointment>>((ref) {
  ref.watch(appointmentProvider);
  return ref.read(appointmentProvider.notifier).getPendingRequests();
});

final reportProvider = StateNotifierProvider<ReportNotifier, List<DoctorReport>>((ref) {
  return ReportNotifier();
});

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<PaymentSummary>>((ref) {
  return PaymentNotifier();
});
