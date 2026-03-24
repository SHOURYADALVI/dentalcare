import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/patient_portal_providers.dart';
import '../../../../core/theme.dart';

class DoctorInfoPage extends ConsumerWidget {
  const DoctorInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Info')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(context, Icons.person_outline, 'Name', doctor.name),
                _row(context, Icons.school_outlined, 'Qualification', doctor.qualification),
                _row(context, Icons.phone_outlined, 'Phone', doctor.phone),
                _row(context, Icons.email_outlined, 'Email', doctor.email),
                _row(context, Icons.location_on_outlined, 'Clinic Address', doctor.clinicAddress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
