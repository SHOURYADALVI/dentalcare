import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/clinic_crud_providers.dart';
import '../../../../core/theme.dart';
import '../../../../models/appointment.dart';
import '../../../../models/payment_summary.dart' as billing;
import '../../../../widgets/cards.dart';

class PatientDetailPage extends ConsumerWidget {
  final String patientId;

  const PatientDetailPage({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientListProvider);
    final appointments = ref.watch(appointmentProvider)
        .where((a) => a.patientId == patientId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final reports = ref.watch(reportProvider)
        .where((r) => r.patientId == patientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final completedPreviousAppointments = ref
        .watch(appointmentProvider)
        .where(
          (a) =>
              a.patientId == patientId &&
              a.status == AppointmentStatus.completed &&
              a.appointmentDate.isBefore(DateTime.now()),
        )
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final payments = ref.watch(paymentProvider);

    final patientMatches = patients.where((p) => p.id == patientId).toList();
    final patient = patientMatches.isNotEmpty ? patientMatches.first : null;
    final latestReport = reports.isNotEmpty ? reports.first : null;
    final paymentMatches = payments.where((p) => p.patientId == patientId).toList();
    final payment = paymentMatches.isNotEmpty ? paymentMatches.first : null;
    final fallbackPayment = billing.PaymentSummary(
      patientId: patientId,
      total: patient?.totalAmount ?? 0,
      paid: patient?.paidAmount ?? 0,
    );
    final effectivePayment = payment ?? fallbackPayment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed(
                'edit-patient',
                pathParameters: {'patientId': patientId},
              );
            },
          ),
        ],
      ),
      body: patient == null
          ? const Center(child: Text('Patient not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryLight,
                                ),
                                child: Center(
                                  child: Text(
                                    patient.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.paddingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${patient.age} • ${patient.gender}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(context, 'Phone:', patient.phone, Icons.phone),
                          _buildDetailRow(context, 'Email:', patient.email ?? 'N/A', Icons.email),
                          _buildDetailRow(context, 'Address:', patient.address ?? 'N/A', Icons.location_on),
                          _buildDetailRow(
                            context,
                            'Emergency:',
                            patient.emergencyContact ?? 'N/A',
                            Icons.phone_missed,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text('Medical History', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      child: Text(patient.medicalHistory),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text('Appointments', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (appointments.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.paddingMedium),
                        child: Text('No appointments'),
                      ),
                    )
                  else
                    Column(
                      children: appointments
                          .map(
                            (apt) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: Text(
                                  '${apt.appointmentDate.day}/${apt.appointmentDate.month}/${apt.appointmentDate.year}',
                                ),
                                subtitle: Text(apt.dentistName ?? 'Unknown dentist'),
                                trailing: StatusBadge(status: apt.status.displayName),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text('Latest Doctor Report', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (latestReport == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.paddingMedium),
                        child: Text('No report available yet'),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Diagnosis: ${latestReport.diagnosis}'),
                            const SizedBox(height: 6),
                            Text('Treatment: ${latestReport.treatment}'),
                            const SizedBox(height: 6),
                            Text('Medicines: ${latestReport.medicines}'),
                            const SizedBox(height: 6),
                            Text('Precautions: ${latestReport.precautions}'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text(
                    'Completed Previous Appointments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (completedPreviousAppointments.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.paddingMedium),
                        child: Text('No completed previous appointments yet.'),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: completedPreviousAppointments
                              .map(
                                (apt) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    '${apt.appointmentDate.day}/${apt.appointmentDate.month}/${apt.appointmentDate.year} • ${apt.startTime.hour.toString().padLeft(2, '0')}:${apt.startTime.minute.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text('Payment Summary', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: ₹${effectivePayment.total.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text('Paid: ₹${effectivePayment.paid.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text('Remaining: ₹${effectivePayment.remaining.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.pushNamed('appointments'),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book Appointment'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.pushNamed(
                            'edit-patient',
                            pathParameters: {'patientId': patientId},
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Patient'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
