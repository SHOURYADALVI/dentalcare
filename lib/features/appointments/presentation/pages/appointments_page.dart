import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;
import '../../../../core/providers/clinic_crud_providers.dart';
import '../../../../core/theme.dart';
import '../../../../models/appointment.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentProvider);
    final appointmentsForDay = appointments.where((apt) {
      return apt.appointmentDate.year == _selectedDay.year &&
          apt.appointmentDate.month == _selectedDay.month &&
          apt.appointmentDate.day == _selectedDay.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            Wrap(
              spacing: AppTheme.paddingMedium,
              runSpacing: AppTheme.paddingSmall,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(140, MediaQuery.of(context).size.width - 170),
                  ),
                  child: Text(
                    'Appointments for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNewAppointmentDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            if (appointmentsForDay.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: AppTheme.dividerColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No appointments scheduled for this day',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: appointmentsForDay
                    .map((apt) => _AppointmentTile(appointment: apt))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showNewAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _NewAppointmentDialog(selectedDate: _selectedDay),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.patientName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _StatusBadge(status: appointment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Dentist: ${appointment.dentistName ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (appointment.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${appointment.notes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.primaryColor;
    if (status == AppointmentStatus.requested) {
      color = AppTheme.warningColor;
    } else if (status == AppointmentStatus.scheduled) {
      color = AppTheme.accentColor;
    } else if (status == AppointmentStatus.completed) {
      color = AppTheme.successColor;
    } else if (status == AppointmentStatus.cancelled) {
      color = AppTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _NewAppointmentDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const _NewAppointmentDialog({required this.selectedDate});

  @override
  ConsumerState<_NewAppointmentDialog> createState() => _NewAppointmentDialogState();
}

class _NewAppointmentDialogState extends ConsumerState<_NewAppointmentDialog> {
  String? _selectedPatientId;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientListProvider);

    return AlertDialog(
      title: const Text('New Appointment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPatientId,
              items: patients
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatientId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Patient'),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Start Time: ${_startTime?.format(context) ?? '-'}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _startTime = time);
                }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('End Time: ${_endTime?.format(context) ?? '-'}'),
              trailing: const Icon(Icons.access_time_filled),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1),
                );
                if (time != null) {
                  setState(() => _endTime = time);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_selectedPatientId == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final patients = ref.read(patientListProvider);
      final patient = patients.where((p) => p.id == _selectedPatientId).toList();
      final selected = patient.isNotEmpty ? patient.first : null;
      if (selected == null) {
        throw Exception('Patient not found');
      }

      final start = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final end = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final appointment = Appointment(
        patientId: selected.id,
        patientName: selected.name,
        appointmentDate: widget.selectedDate,
        startTime: start,
        endTime: end,
        dentistName: 'Dr. Priya Sharma',
        status: AppointmentStatus.scheduled,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      ref.read(appointmentProvider.notifier).addAppointment(appointment);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
