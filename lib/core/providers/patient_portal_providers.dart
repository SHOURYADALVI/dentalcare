import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/appointment.dart';
import '../../models/doctor_report.dart';
import '../../models/patient.dart';
import '../../models/patient_portal.dart';
import 'auth_providers.dart';
import 'clinic_crud_providers.dart';

final patientProfileProvider = Provider<Patient?>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  final patients = ref.watch(patientListProvider);
  if (userId == null) return null;

  try {
    return patients.firstWhere((p) => p.id == userId);
  } catch (_) {
    return null;
  }
});

final patientAppointmentsProvider = Provider<List<PatientAppointmentItem>>((ref) {
  final patient = ref.watch(patientProfileProvider);
  final appointments = ref.watch(appointmentProvider);

  if (patient == null) {
    return [];
  }

  String fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String mapStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.requested:
        return 'Pending';
      case AppointmentStatus.scheduled:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Rejected';
    }
  }

  return appointments
      .where((a) => a.patientId == patient.id)
      .map(
        (a) => PatientAppointmentItem(
          id: a.id,
          date: a.appointmentDate,
          time: a.status == AppointmentStatus.requested && a.preferredStartTime == null
              ? 'Awaiting slot assignment'
              : fmt(a.startTime),
          doctorName: a.dentistName ?? 'Doctor',
          consultationFee: 500,
          status: mapStatus(a.status),
          reasonForVisit: a.reasonForVisit,
          rejectionReason: a.rejectionReason,
        ),
      )
      .toList();
});

final upcomingPatientAppointmentProvider = Provider<PatientAppointmentItem?>((ref) {
  final appointments = ref.watch(patientAppointmentsProvider)
      .where((a) => a.date.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  if (appointments.isEmpty) {
    return null;
  }
  return appointments.first;
});

final paymentSummaryProvider = Provider<PaymentSummary>((ref) {
  final patient = ref.watch(patientProfileProvider);
  final payments = ref.watch(paymentProvider);
  if (patient == null) {
    return const PaymentSummary(totalAmount: 0, paidAmount: 0);
  }

  final summary = payments.where((p) => p.patientId == patient.id).toList();
  final item = summary.isNotEmpty ? summary.first : null;
  return PaymentSummary(
    totalAmount: item?.total ?? patient.totalAmount ?? 0,
    paidAmount: item?.paid ?? patient.paidAmount ?? 0,
  );
});

final patientReportProvider = Provider<PatientReport>((ref) {
  final patient = ref.watch(patientProfileProvider);
  final reports = ref.watch(reportProvider);
  DoctorReport? selected;
  if (patient != null) {
    final list = reports.where((r) => r.patientId == patient.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (list.isNotEmpty) {
      selected = list.first;
    }
  }

  return PatientReport(
    patientName: patient?.name ?? 'N/A',
    age: patient?.age ?? 0,
    phone: patient?.phone ?? 'N/A',
    diagnosis: selected?.diagnosis ?? 'No diagnosis yet',
    treatment: selected?.treatment ?? 'No treatment plan yet',
    medicines: selected?.medicines ?? 'No medicines prescribed',
    precautions: selected?.precautions ?? 'No precautions added',
    visitDate: selected?.createdAt ?? DateTime.now(),
  );
});

final doctorInfoProvider = Provider<DoctorInfo>((ref) {
  final doctor = ref.watch(doctorProvider);
  return DoctorInfo(
    name: doctor.name,
    qualification: doctor.qualification,
    phone: doctor.phone,
    email: doctor.email,
    clinicAddress: doctor.clinicAddress,
  );
});
