import 'package:uuid/uuid.dart';

class DoctorReport {
  final String id;
  final String patientId;
  final String doctorId;
  final String diagnosis;
  final String treatment;
  final String medicines;
  final String precautions;
  final DateTime createdAt;

  DoctorReport({
    String? id,
    required this.patientId,
    required this.doctorId,
    required this.diagnosis,
    required this.treatment,
    required this.medicines,
    required this.precautions,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  DoctorReport copyWith({
    String? diagnosis,
    String? treatment,
    String? medicines,
    String? precautions,
  }) {
    return DoctorReport(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      medicines: medicines ?? this.medicines,
      precautions: precautions ?? this.precautions,
      createdAt: createdAt,
    );
  }

  factory DoctorReport.fromJson(Map<String, dynamic> json) {
    return DoctorReport(
      id: json['id'] as String?,
      patientId: (json['patientId'] ?? '') as String,
      doctorId: (json['doctorId'] ?? '') as String,
      diagnosis: (json['diagnosis'] ?? '') as String,
      treatment: (json['treatment'] ?? '') as String,
      medicines: (json['medicines'] ?? '') as String,
      precautions: (json['precautions'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medicines': medicines,
      'precautions': precautions,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
