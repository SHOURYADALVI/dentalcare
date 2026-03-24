import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/patient_portal.dart';
import 'ui_components.dart';

class PaymentSummaryCard extends StatelessWidget {
  final PaymentSummary summary;

  const PaymentSummaryCard({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ratio = summary.totalAmount == 0
        ? 0.0
        : (summary.paidAmount / summary.totalAmount).clamp(0.0, 1.0);

    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            _RowItem(label: 'Total', amount: summary.totalAmount),
            const SizedBox(height: 8),
            _RowItem(
              label: 'Paid',
              amount: summary.paidAmount,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 8),
            _RowItem(
              label: 'Remaining',
              amount: summary.remainingAmount,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: AppTheme.dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}% paid',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;

  const _RowItem({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color ?? AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}
