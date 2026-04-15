import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/patient_portal_providers.dart';
import '../../../../core/theme.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/ui_components.dart';

class PatientDashboardPage extends ConsumerWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final upcomingAppointment = ref.watch(upcomingPatientAppointmentProvider);
    final summary = ref.watch(paymentSummaryProvider);
    final firstName = (user?.name.split(' ').first ?? 'Patient').trim();

    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      body: FadeInView(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Hello, $firstName 👋',
                subtitle: 'Here is your health summary for today',
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              CustomCard(
                color: AppTheme.primaryLight,
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          ),
                          child: const Icon(Icons.local_hospital, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your care is on track. Keep up with appointments and treatment plans.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/patient/appointments'),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Request Appointment'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              const SectionTitle(title: 'Upcoming Appointment'),
              const SizedBox(height: AppTheme.paddingMedium),
              CustomCard(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: upcomingAppointment == null
                    ? const InfoRow(
                        icon: Icons.event_busy,
                        label: 'Status',
                        value: 'No upcoming appointment',
                      )
                    : Column(
                        children: [
                          InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value:
                                '${upcomingAppointment.date.day}/${upcomingAppointment.date.month}/${upcomingAppointment.date.year}',
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: upcomingAppointment.time,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.flag_circle_outlined,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              const Text('Status'),
                              const Spacer(),
                              StatusChip(status: upcomingAppointment.status),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              PaymentSummaryCard(summary: summary),
              const SizedBox(height: AppTheme.paddingLarge),
              const SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: AppTheme.paddingMedium),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 620;
                  return Wrap(
                    spacing: AppTheme.paddingMedium,
                    runSpacing: AppTheme.paddingMedium,
                    children: [
                      _ActionTile(
                        width: isWide
                            ? (constraints.maxWidth - AppTheme.paddingMedium) / 2
                            : constraints.maxWidth,
                        title: 'View Report',
                        icon: Icons.description_outlined,
                        onTap: () => context.push('/patient/report'),
                      ),
                      _ActionTile(
                        width: isWide
                            ? (constraints.maxWidth - AppTheme.paddingMedium) / 2
                            : constraints.maxWidth,
                        title: 'Doctor Info',
                        icon: Icons.medical_information_outlined,
                        onTap: () => context.push('/patient/doctor-info'),
                      ),
                      _ActionTile(
                        width: isWide
                            ? (constraints.maxWidth - AppTheme.paddingMedium) / 2
                            : constraints.maxWidth,
                        title: 'Appointments',
                        icon: Icons.event_note_outlined,
                        onTap: () => context.push('/patient/appointments'),
                      ),
                      _ActionTile(
                        width: isWide
                            ? (constraints.maxWidth - AppTheme.paddingMedium) / 2
                            : constraints.maxWidth,
                        title: 'Payments',
                        icon: Icons.payments_outlined,
                        onTap: () => context.push('/patient/payments'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final double width;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.width,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
