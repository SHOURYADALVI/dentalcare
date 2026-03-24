import 'package:uuid/uuid.dart';

/// Treatment model represents a dental treatment record
class Treatment {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime treatmentDate;
  final String diagnosis;
  final String procedure;
  final String? notes;
  final double cost;
  final String? dentistName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Treatment({
    String? id,
    required this.patientId,
    required this.patientName,
    required this.treatmentDate,
    required this.diagnosis,
    required this.procedure,
    this.notes,
    required this.cost,
    this.dentistName,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of treatment with modified fields
  Treatment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    DateTime? treatmentDate,
    String? diagnosis,
    String? procedure,
    String? notes,
    double? cost,
    String? dentistName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Treatment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      treatmentDate: treatmentDate ?? this.treatmentDate,
      diagnosis: diagnosis ?? this.diagnosis,
      procedure: procedure ?? this.procedure,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
      dentistName: dentistName ?? this.dentistName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Treatment(id: $id, patientId: $patientId, procedure: $procedure, cost: $cost)';
  }
}
