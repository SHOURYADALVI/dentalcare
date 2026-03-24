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
const _reportsStorageKey = 'dentlink_reports';
const _paymentsStorageKey = 'dentlink_payments';
final _store = createLocalStore();

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
  AppointmentNotifier()
      : super([
          Appointment(
            id: 'apt-001',
            patientId: '1',
            patientName: 'Aarya Patil',
            appointmentDate: DateTime.now(),
            startTime: DateTime.now().copyWith(hour: 10, minute: 0),
            endTime: DateTime.now().copyWith(hour: 10, minute: 45),
            dentistName: 'Dr. Priya Sharma',
            status: AppointmentStatus.scheduled,
          ),
          Appointment(
            id: 'apt-002',
            patientId: '2',
            patientName: 'Rohit Singh',
            appointmentDate: DateTime.now(),
            startTime: DateTime.now().copyWith(hour: 11, minute: 30),
            endTime: DateTime.now().copyWith(hour: 12, minute: 15),
            dentistName: 'Dr. Priya Sharma',
            status: AppointmentStatus.completed,
          ),
        ]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _store.getString(_appointmentsStorageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
    await purgeExpiredCompletedAppointments();
  }

  Future<void> _persist() async {
    final encoded = state.map((a) => a.toJson()).toList();
    await _store.setString(_appointmentsStorageKey, jsonEncode(encoded));
  }

  bool _hasConflict(Appointment target) {
    for (final apt in state) {
      if (apt.id == target.id) continue;
      if (apt.status == AppointmentStatus.cancelled) continue;
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

final reportProvider = StateNotifierProvider<ReportNotifier, List<DoctorReport>>((ref) {
  return ReportNotifier();
});

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<PaymentSummary>>((ref) {
  return PaymentNotifier();
});
