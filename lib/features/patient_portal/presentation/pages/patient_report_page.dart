import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/patient_portal_providers.dart';
import '../../../../core/theme.dart';

class PatientReportPage extends ConsumerWidget {
  const PatientReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(patientReportProvider);
    final hasReportAccess = report.patientName != 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Report')),
      body: hasReportAccess
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _item(context, 'Patient Name', report.patientName),
                      _item(context, 'Age', report.age.toString()),
                      _item(context, 'Phone', report.phone),
                      _item(context, 'Diagnosis', report.diagnosis),
                      _item(context, 'Treatment', report.treatment),
                      _item(context, 'Medicines', report.medicines),
                      _item(context, 'Precautions', report.precautions),
                      _item(
                        context,
                        'Visit Date',
                        '${report.visitDate.day}/${report.visitDate.month}/${report.visitDate.year}',
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingLarge),
                child: Text(
                  'No report access for this account. Please login with your patient account.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    );
  }

  Widget _item(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
