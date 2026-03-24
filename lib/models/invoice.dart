import 'package:uuid/uuid.dart';
import 'treatment.dart';

/// Enum for payment status
enum PaymentStatus {
  pending('Pending'),
  paid('Paid'),
  overdue('Overdue');

  final String displayName;

  const PaymentStatus(this.displayName);
}

/// Invoice model represents a billing invoice
class Invoice {
  final String id;
  final String patientId;
  final String patientName;
  final List<Treatment> treatments;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final DateTime issuedDate;
  final DateTime? paidDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    String? id,
    required this.patientId,
    required this.patientName,
    required this.treatments,
    required this.totalAmount,
    this.paymentStatus = PaymentStatus.pending,
    DateTime? issuedDate,
    this.paidDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        issuedDate = issuedDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate total from treatments
  static double calculateTotal(List<Treatment> treatments) {
    return treatments.fold(0.0, (sum, treatment) => sum + treatment.cost);
  }

  /// Create a copy of invoice with modified fields
  Invoice copyWith({
    String? id,
    String? patientId,
    String? patientName,
    List<Treatment>? treatments,
    double? totalAmount,
    PaymentStatus? paymentStatus,
    DateTime? issuedDate,
    DateTime? paidDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      treatments: treatments ?? this.treatments,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      issuedDate: issuedDate ?? this.issuedDate,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Invoice(id: $id, patientId: $patientId, totalAmount: $totalAmount, paymentStatus: ${paymentStatus.displayName})';
  }
}
