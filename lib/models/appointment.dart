import 'package:uuid/uuid.dart';

/// Enum for appointment status
enum AppointmentStatus {
  requested('Pending Approval'),
  scheduled('Booked'),
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
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
