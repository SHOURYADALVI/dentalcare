class PaymentSummary {
  final double totalAmount;
  final double paidAmount;

  const PaymentSummary({
    required this.totalAmount,
    required this.paidAmount,
  });

  double get remainingAmount => totalAmount - paidAmount;
}

class PatientAppointmentItem {
  final String id;
  final DateTime date;
  final String time;
  final String doctorName;
  final double consultationFee;
  final String status;
  final String? reasonForVisit;
  final String? rejectionReason;

  const PatientAppointmentItem({
    required this.id,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.consultationFee,
    required this.status,
    this.reasonForVisit,
    this.rejectionReason,
  });
}

class PatientReport {
  final String patientName;
  final int age;
  final String phone;
  final String diagnosis;
  final String treatment;
  final String medicines;
  final String precautions;
  final DateTime visitDate;

  const PatientReport({
    required this.patientName,
    required this.age,
    required this.phone,
    required this.diagnosis,
    required this.treatment,
    required this.medicines,
    required this.precautions,
    required this.visitDate,
  });
}

class DoctorInfo {
  final String name;
  final String qualification;
  final String phone;
  final String email;
  final String clinicAddress;

  const DoctorInfo({
    required this.name,
    required this.qualification,
    required this.phone,
    required this.email,
    required this.clinicAddress,
  });
}
