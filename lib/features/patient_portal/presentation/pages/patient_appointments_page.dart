import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/clinic_crud_providers.dart';
import '../../../../core/providers/patient_portal_providers.dart';
import '../../../../core/theme.dart';
import '../../../../models/appointment.dart';

class PatientAppointmentsPage extends ConsumerStatefulWidget {
  const PatientAppointmentsPage({super.key});

  @override
  ConsumerState<PatientAppointmentsPage> createState() => _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends ConsumerState<PatientAppointmentsPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedSlot;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('pending')) return AppTheme.warningColor;
    if (normalized.contains('confirmed')) return AppTheme.successColor;
    if (normalized.contains('completed')) return AppTheme.primaryColor;
    if (normalized.contains('rejected')) return AppTheme.errorColor;
    return AppTheme.primaryColor;
  }

  String _formatSlotLabel(DateTime start) {
    final end = start.add(const Duration(hours: 1));
    return '${_formatHour(start)} - ${_formatHour(end)}';
  }

  String _formatHour(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:00 $suffix';
  }

  Appointment? _bookedAppointmentForSlot(List<Appointment> appointments, DateTime slot) {
    for (final apt in appointments) {
      if (apt.status != AppointmentStatus.scheduled && apt.status != AppointmentStatus.completed) {
        continue;
      }

      final sameDay = apt.appointmentDate.year == slot.year &&
          apt.appointmentDate.month == slot.month &&
          apt.appointmentDate.day == slot.day;
      if (!sameDay) continue;

      if (apt.startTime.hour == slot.hour) {
        return apt;
      }
    }
    return null;
  }

  Future<void> _confirmAppointment() async {
    final patient = ref.read(patientProfileProvider);
    if (patient == null || _selectedSlot == null || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a slot and enter a reason for visit.')),
      );
      return;
    }

    final preferredStart = _selectedSlot!;
    final preferredEnd = _selectedSlot!.add(const Duration(hours: 1));

    try {
      await ref.read(appointmentProvider.notifier).requestAppointment(
            patientId: patient.id,
            patientName: patient.name,
            preferredDate: _selectedDate,
            preferredStartTime: preferredStart,
            preferredEndTime: preferredEnd,
            reasonForVisit: _reasonController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment request sent for approval.')),
      );
      setState(() {
        _selectedSlot = null;
        _reasonController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to request appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientAppointments = ref.watch(patientAppointmentsProvider);
    final allAppointments = ref.watch(appointmentProvider);
    final patient = ref.watch(patientProfileProvider);
    final appointmentNotifier = ref.read(appointmentProvider.notifier);
    final slots = appointmentNotifier.buildHourlySlotsForDate(_selectedDate);
    final availability = ref.watch(clinicAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Appointment',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a date and a 1-hour slot. The doctor will review your request.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _selectedSlot = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Working hours: ${_formatHour(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, availability.startHour))} - ${_formatHour(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, availability.endHour))}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 3
                          : constraints.maxWidth >= 600
                              ? 3
                              : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slots.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 92,
                        ),
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final booked = _bookedAppointmentForSlot(allAppointments, slot);
                          final isBooked = booked != null;
                          final isPending = appointmentNotifier.isSlotPending(slot) && !isBooked;
                          final isSelected = _selectedSlot != null &&
                              _selectedSlot!.year == slot.year &&
                              _selectedSlot!.month == slot.month &&
                              _selectedSlot!.day == slot.day &&
                              _selectedSlot!.hour == slot.hour;

                          final color = isBooked
                              ? AppTheme.errorColor
                              : (isPending ? AppTheme.warningColor : AppTheme.successColor);
                          final label = isBooked
                              ? 'Booked'
                              : (isPending ? 'Pending' : 'Available');

                          return AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            scale: isSelected ? 1.02 : 1.0,
                            child: InkWell(
                              onTap: isBooked
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedSlot = slot;
                                      });
                                    },
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryLight
                                      : color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : color.withValues(alpha: 0.35),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatSlotLabel(slot),
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isBooked ? Colors.grey.shade700 : AppTheme.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: color,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isBooked) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        booked.patientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade700,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  if (_selectedSlot != null)
                    Card(
                      color: AppTheme.primaryLight,
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Slot',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} • ${_formatSlotLabel(_selectedSlot!)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextField(
                    controller: _reasonController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reason for visit',
                      hintText: 'Describe symptoms or treatment need',
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectedSlot == null ? null : _confirmAppointment,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm Appointment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Text(
            'My Requests & Appointments',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          if (patientAppointments.isEmpty)
            const Center(child: Text('No appointments yet.'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patientAppointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = patientAppointments[index];
                final color = _statusColor(item.status);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: Card(
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
                          if (item.reasonForVisit != null && item.reasonForVisit!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${item.reasonForVisit}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
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
                          if (item.rejectionReason != null && item.rejectionReason!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Rejection reason: ${item.rejectionReason}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: patient == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _confirmAppointment,
              icon: const Icon(Icons.add),
              label: const Text('Confirm Appointment'),
            ),
    );
  }
}
