import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../core/providers/treatment_providers.dart';
import '../../../../models/invoice.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentsAsync = ref.watch(treatmentsProvider);
    final totalRevenueAsync = ref.watch(totalRevenueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Revenue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue summary
            totalRevenueAsync.when(
              data: (revenue) {
                return Card(
                  color: AppTheme.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Column(
                      children: [
                        Text(
                          'Total Revenue',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${revenue.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.paddingLarge),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Text('Error loading revenue: $error'),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Treatment list with billing details
            Text(
              'Treatment Invoices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.paddingMedium),

            treatmentsAsync.when(
              data: (treatments) {
                if (treatments.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 48,
                              color: AppTheme.dividerColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No invoices',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: treatments
                      .map((treatment) => _InvoiceCard(
                            treatment: treatment,
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Center(
                    child: Text('Error loading invoices: $error'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends ConsumerStatefulWidget {
  final dynamic treatment;

  const _InvoiceCard({required this.treatment});

  @override
  ConsumerState<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends ConsumerState<_InvoiceCard> {
  late PaymentStatus _paymentStatus;

  @override
  void initState() {
    super.initState();
    _paymentStatus = PaymentStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    final treatment = widget.treatment;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INV-${treatment.id.substring(0, 8).toUpperCase()}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        treatment.patientName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_paymentStatus),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    _paymentStatus.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treatment',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                    Text(
                      treatment.procedure,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                    Text(
                      '\$${treatment.cost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppTheme.accentColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${treatment.treatmentDate.day}/${treatment.treatmentDate.month}/${treatment.treatmentDate.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Dentist: ${treatment.dentistName ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            // Payment status toggle
            if (_paymentStatus == PaymentStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _paymentStatus = PaymentStatus.paid;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment marked as paid'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    },
                    child: const Text('Mark as Paid'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.successColor;
      case PaymentStatus.pending:
        return AppTheme.warningColor;
      case PaymentStatus.overdue:
        return AppTheme.errorColor;
    }
  }
}
