class PaymentSummary {
  final String patientId;
  final double total;
  final double paid;

  const PaymentSummary({
    required this.patientId,
    required this.total,
    required this.paid,
  });

  double get remaining => total - paid;

  PaymentSummary copyWith({
    String? patientId,
    double? total,
    double? paid,
  }) {
    return PaymentSummary(
      patientId: patientId ?? this.patientId,
      total: total ?? this.total,
      paid: paid ?? this.paid,
    );
  }

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      patientId: (json['patientId'] ?? '') as String,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paid: (json['paid'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'total': total,
      'paid': paid,
    };
  }
}
