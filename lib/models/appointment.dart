import 'package:uuid/uuid.dart';

/// Enum for appointment status
enum AppointmentStatus {
  requested('Pending'),
  scheduled('Confirmed'),
  completed('Completed'),
  cancelled('Rejected');

  final String displayName;

  const AppointmentStatus(this.displayName);
}

/// Appointment model represents a patient appointment
class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime appointmentDate;
  final DateTime startTime;
  final DateTime endTime;
  final String? dentistName;
  final String? notes;
  final String? reasonForVisit;
  final DateTime? preferredStartTime;
  final DateTime? preferredEndTime;
  final String? rejectionReason;
  final AppointmentStatus status;
  final DateTime createdAt;

  Appointment({
    String? id,
    required this.patientId,
    required this.patientName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.dentistName,
    this.notes,
    this.reasonForVisit,
    this.preferredStartTime,
    this.preferredEndTime,
    this.rejectionReason,
    this.status = AppointmentStatus.scheduled,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Check if appointment conflicts with another appointment
  bool conflictsWith(Appointment other) {
    if (appointmentDate.year != other.appointmentDate.year ||
        appointmentDate.month != other.appointmentDate.month ||
        appointmentDate.day != other.appointmentDate.day) {
      return false;
    }

    // Check if time overlaps
    return !(endTime.isBefore(other.startTime) ||
        startTime.isAfter(other.endTime));
  }

  /// Create a copy of appointment with modified fields
  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    DateTime? appointmentDate,
    DateTime? startTime,
    DateTime? endTime,
    String? dentistName,
    String? notes,
    String? reasonForVisit,
    DateTime? preferredStartTime,
    DateTime? preferredEndTime,
    String? rejectionReason,
    AppointmentStatus? status,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dentistName: dentistName ?? this.dentistName,
      notes: notes ?? this.notes,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      preferredStartTime: preferredStartTime ?? this.preferredStartTime,
      preferredEndTime: preferredEndTime ?? this.preferredEndTime,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, patientId: $patientId, appointmentDate: $appointmentDate, status: ${status.displayName})';
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String?,
      patientId: (json['patientId'] ?? '') as String,
      patientName: (json['patientName'] ?? '') as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      dentistName: json['dentistName'] as String?,
      notes: json['notes'] as String?,
        reasonForVisit: json['reasonForVisit'] as String?,
        preferredStartTime: json['preferredStartTime'] != null
          ? DateTime.parse(json['preferredStartTime'] as String)
          : null,
        preferredEndTime: json['preferredEndTime'] != null
          ? DateTime.parse(json['preferredEndTime'] as String)
          : null,
        rejectionReason: json['rejectionReason'] as String?,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'dentistName': dentistName,
      'notes': notes,
      'reasonForVisit': reasonForVisit,
      'preferredStartTime': preferredStartTime?.toIso8601String(),
      'preferredEndTime': preferredEndTime?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
