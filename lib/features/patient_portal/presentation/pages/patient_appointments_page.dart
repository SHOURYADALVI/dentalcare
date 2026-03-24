import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/clinic_crud_providers.dart';
import '../../../../core/providers/patient_portal_providers.dart';
import '../../../../core/theme.dart';
import '../../../../models/appointment.dart';

class PatientAppointmentsPage extends ConsumerWidget {
  const PatientAppointmentsPage({Key? key}) : super(key: key);

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('pending')) return AppTheme.warningColor;
    if (normalized.contains('booked')) return AppTheme.successColor;
    if (normalized.contains('completed')) return AppTheme.primaryColor;
    if (normalized.contains('rejected')) return AppTheme.errorColor;
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(patientAppointmentsProvider);
    final patient = ref.watch(patientProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: appointments.isEmpty
          ? const Center(child: Text('No appointments yet. Request one with the + button.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = appointments[index];
                final color = _statusColor(item.status);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.date.day}/${item.date.month}/${item.date.year} • ${item.time}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Doctor: ${item.doctorName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Consultation Fee: ₹${item.consultationFee.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Text(
                            item.status,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: patient == null
            ? null
            : () => _showRequestAppointmentDialog(context, ref, patient.id, patient.name),
        icon: const Icon(Icons.add),
        label: const Text('Request Appointment'),
      ),
    );
  }
}

Future<void> _showRequestAppointmentDialog(
  BuildContext context,
  WidgetRef ref,
  String patientId,
  String patientName,
) async {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 45);
  final notesController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Request Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Start Time: ${startTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('End Time: ${endTime.format(context)}'),
                trailing: const Icon(Icons.access_time_filled),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
                  }
                },
              ),
              TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Symptoms or preferred slot notes',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final start = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                startTime.hour,
                startTime.minute,
              );
              final end = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                endTime.hour,
                endTime.minute,
              );

              if (!end.isAfter(start)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('End time must be after start time.')),
                );
                return;
              }

              try {
                await ref.read(appointmentProvider.notifier).addAppointment(
                      Appointment(
                        patientId: patientId,
                        patientName: patientName,
                        appointmentDate: selectedDate,
                        startTime: start,
                        endTime: end,
                        dentistName: 'Dr. Priya Sharma',
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                        status: AppointmentStatus.requested,
                      ),
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment request sent to doctor for approval.'),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Requested slot is unavailable. Please choose another time.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    ),
  );
}
