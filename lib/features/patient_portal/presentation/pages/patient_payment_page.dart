import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/patient_portal_providers.dart';
import '../../../../core/theme.dart';
import '../widgets/payment_summary_card.dart';

class PatientPaymentPage extends ConsumerWidget {
  const PatientPaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(paymentSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentSummaryCard(summary: summary),
          ],
        ),
      ),
    );
  }
}
