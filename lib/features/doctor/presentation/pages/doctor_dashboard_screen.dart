import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/clinic_crud_providers.dart';
import '../../../../core/theme.dart';
import '../../../../models/appointment.dart';
import '../../../../models/doctor_profile.dart';
import '../../../../models/doctor_report.dart';
import '../../../../models/patient.dart';
import '../../../../models/payment_summary.dart';
import '../../../../widgets/buttons.dart';
import '../../../../widgets/cards.dart';
import '../../../../widgets/form_fields.dart';
import '../widgets/profile_card.dart';
import '../widgets/section_title.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  final String portalTitle;

  const DoctorDashboardScreen({
    Key? key,
    this.portalTitle = 'DENTLINK Doctor Dashboard',
  }) : super(key: key);

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DoctorHomeTab(),
      const _DoctorAppointmentsTab(),
      const _DoctorPatientsTab(),
      const _DoctorReportsTab(),
      const _DoctorProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.portalTitle)),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Appointments'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Patients'),
          NavigationDestination(icon: Icon(Icons.description_outlined), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DoctorHomeTab extends ConsumerWidget {
  const _DoctorHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorProvider);
    final patients = ref.watch(patientListProvider);
    final appointments = ref.watch(appointmentProvider);
    final payments = ref.watch(paymentProvider);

    final today = DateTime.now();
    final todayAppointments = appointments.where((a) {
      return a.appointmentDate.year == today.year &&
          a.appointmentDate.month == today.month &&
          a.appointmentDate.day == today.day;
    }).toList();

    final totalRevenue = payments.fold<double>(0, (sum, p) => sum + p.paid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(doctor: doctor),
          const SizedBox(height: AppTheme.paddingLarge),
          const SectionTitle(title: 'Overview'),
          const SizedBox(height: AppTheme.paddingMedium),
          InfoCard(
            title: 'Total Patients',
            value: '${patients.length}',
            icon: Icons.people_alt_outlined,
            iconColor: AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          InfoCard(
            title: "Today's Appointments",
            value: '${todayAppointments.length}',
            icon: Icons.today_outlined,
            iconColor: AppTheme.warningColor,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          InfoCard(
            title: 'Total Revenue',
            value: '₹${totalRevenue.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            iconColor: AppTheme.successColor,
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          const SectionTitle(title: "Today's Appointments"),
          const SizedBox(height: AppTheme.paddingMedium),
          if (todayAppointments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingLarge),
                child: Text('No appointments scheduled for today.'),
              ),
            )
          else
            Column(
              children: todayAppointments
                  .map((appointment) => _AppointmentTile(appointment: appointment))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DoctorAppointmentsTab extends ConsumerStatefulWidget {
  const _DoctorAppointmentsTab();

  @override
  ConsumerState<_DoctorAppointmentsTab> createState() => _DoctorAppointmentsTabState();
}

class _DoctorAppointmentsTabState extends ConsumerState<_DoctorAppointmentsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(appointmentProvider.notifier).purgeExpiredCompletedAppointments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentProvider);
    final now = DateTime.now();
    final visibleAppointments = appointments.where((a) {
      final appointmentDay = DateTime(
        a.appointmentDate.year,
        a.appointmentDate.month,
        a.appointmentDate.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      return appointmentDay.isAtSameMomentAs(today) || appointmentDay.isAfter(today);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  title: 'Appointments',
                  subtitle: 'Update status and open patient details',
                ),
              ),
              SizedBox(
                width: 130,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddAppointmentDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          if (visibleAppointments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingLarge),
                child: Text('No upcoming appointments.'),
              ),
            )
          else
            Column(
              children: visibleAppointments
                  .map((a) => _AppointmentTile(appointment: a, allowActions: true))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DoctorPatientsTab extends ConsumerStatefulWidget {
  const _DoctorPatientsTab();

  @override
  ConsumerState<_DoctorPatientsTab> createState() => _DoctorPatientsTabState();
}

class _DoctorPatientsTabState extends ConsumerState<_DoctorPatientsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientListProvider);
    final query = _searchController.text.trim().toLowerCase();

    final filtered = patients.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.phone.contains(query) ||
          p.medicalHistory.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  title: 'Patients',
                  subtitle: 'Add, edit and view patient details',
                ),
              ),
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: () => _showPatientFormDialog(context, ref),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add Patient'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search by name, phone, issue',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          if (filtered.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingLarge),
                child: Text('No patients found.'),
              ),
            )
          else
            Column(
              children: filtered
                  .map(
                    (p) => PatientCard(
                      patientName: p.name,
                      phone: p.phone,
                      age: p.age,
                      gender: p.gender,
                      onTap: () => _showPatientDetailsDialog(context, ref, p),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DoctorReportsTab extends ConsumerStatefulWidget {
  const _DoctorReportsTab();

  @override
  ConsumerState<_DoctorReportsTab> createState() => _DoctorReportsTabState();
}

class _DoctorReportsTabState extends ConsumerState<_DoctorReportsTab> {
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _medicinesController = TextEditingController();
  final _precautionsController = TextEditingController();
  String? _patientId;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _medicinesController.dispose();
    _precautionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorProvider);
    final patients = ref.watch(patientListProvider);
    final reports = ref.watch(reportProvider);

    DoctorReport? selectedReport;
    if (_patientId != null) {
      final list = reports.where((r) => r.patientId == _patientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (list.isNotEmpty) {
        selectedReport = list.first;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Create / Update Report',
            subtitle: 'Attach diagnosis, treatment and medications to patient',
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          DropdownButtonFormField<String>(
            value: _patientId,
            items: patients
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _patientId = value;
                final report = reports.where((r) => r.patientId == value).toList();
                if (report.isNotEmpty) {
                  report.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  final latest = report.first;
                  _diagnosisController.text = latest.diagnosis;
                  _treatmentController.text = latest.treatment;
                  _medicinesController.text = latest.medicines;
                  _precautionsController.text = latest.precautions;
                } else {
                  _diagnosisController.clear();
                  _treatmentController.clear();
                  _medicinesController.clear();
                  _precautionsController.clear();
                }
              });
            },
            decoration: const InputDecoration(labelText: 'Select Patient'),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          CustomTextField(
            label: 'Diagnosis',
            controller: _diagnosisController,
            maxLines: 3,
            hint: 'Enter dental issue diagnosis',
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          CustomTextField(
            label: 'Treatment',
            controller: _treatmentController,
            maxLines: 3,
            hint: 'Enter treatment details',
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          CustomTextField(
            label: 'Medicines',
            controller: _medicinesController,
            maxLines: 3,
            hint: 'Enter prescribed medicines',
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          CustomTextField(
            label: 'Precautions',
            controller: _precautionsController,
            maxLines: 3,
            hint: 'Enter precautions',
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          PrimaryButton(
            label: 'Save Report',
            icon: Icons.save_outlined,
            onPressed: () async {
              if (_patientId == null ||
                  _diagnosisController.text.trim().isEmpty ||
                  _treatmentController.text.trim().isEmpty ||
                  _medicinesController.text.trim().isEmpty ||
                  _precautionsController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please complete all report fields.')),
                );
                return;
              }

              await ref.read(reportProvider.notifier).upsertReport(
                    DoctorReport(
                      patientId: _patientId!,
                      doctorId: doctor.id,
                      diagnosis: _diagnosisController.text.trim(),
                      treatment: _treatmentController.text.trim(),
                      medicines: _medicinesController.text.trim(),
                      precautions: _precautionsController.text.trim(),
                    ),
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report saved successfully.')),
              );
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          if (selectedReport != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Report', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Diagnosis: ${selectedReport.diagnosis}'),
                    const SizedBox(height: 4),
                    Text('Treatment: ${selectedReport.treatment}'),
                    const SizedBox(height: 4),
                    Text('Medicines: ${selectedReport.medicines}'),
                    const SizedBox(height: 4),
                    Text('Precautions: ${selectedReport.precautions}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DoctorProfileTab extends ConsumerWidget {
  const _DoctorProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(doctor: doctor),
          const SizedBox(height: AppTheme.paddingMedium),
          SizedBox(
            width: 180,
            child: ElevatedButton.icon(
              onPressed: () => _showDoctorEditDialog(context, ref, doctor),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  final Appointment appointment;
  final bool allowActions;

  const _AppointmentTile({
    required this.appointment,
    this.allowActions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
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
                StatusBadge(status: appointment.status.displayName),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            if (allowActions)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final patient = ref
                            .read(patientListProvider)
                            .firstWhere((p) => p.id == appointment.patientId);
                        _showPatientDetailsDialog(context, ref, patient);
                      },
                      child: const Text('View Patient'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (appointment.status == AppointmentStatus.requested) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref.read(appointmentProvider.notifier).updateAppointment(
                                appointment.copyWith(status: AppointmentStatus.scheduled),
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Appointment accepted and booked.')),
                            );
                          }
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await ref.read(appointmentProvider.notifier).updateAppointment(
                                appointment.copyWith(status: AppointmentStatus.cancelled),
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Appointment request rejected.')),
                            );
                          }
                        },
                        child: const Text('Reject'),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: DropdownButtonFormField<AppointmentStatus>(
                        value: appointment.status,
                        items: AppointmentStatus.values
                            .where((s) => s != AppointmentStatus.requested)
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName)))
                            .toList(),
                        onChanged: (value) async {
                          if (value == null) return;
                          try {
                            await ref.read(appointmentProvider.notifier).updateAppointment(
                                  appointment.copyWith(status: value),
                                );
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to update appointment status.'),
                                ),
                              );
                            }
                          }
                        },
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddAppointmentDialog(BuildContext context, WidgetRef ref) async {
  String? selectedPatientId;
  DateTime date = DateTime.now();
  TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 10, minute: 45);

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final patients = ref.read(patientListProvider);
          return AlertDialog(
            title: const Text('Add Appointment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedPatientId,
                  items: patients
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedPatientId = value),
                  decoration: const InputDecoration(labelText: 'Patient'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Date: ${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Start: ${start.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: start);
                    if (picked != null) setState(() => start = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('End: ${end.format(context)}'),
                  trailing: const Icon(Icons.access_time_filled),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: end);
                    if (picked != null) setState(() => end = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedPatientId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a patient.')),
                    );
                    return;
                  }

                  final patient = ref
                      .read(patientListProvider)
                      .firstWhere((p) => p.id == selectedPatientId);

                  final startDt = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    start.hour,
                    start.minute,
                  );
                  final endDt = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    end.hour,
                    end.minute,
                  );

                  try {
                    await ref.read(appointmentProvider.notifier).addAppointment(
                          Appointment(
                            patientId: patient.id,
                            patientName: patient.name,
                            appointmentDate: date,
                            startTime: startDt,
                            endTime: endDt,
                            dentistName: 'Dr. Priya Sharma',
                            status: AppointmentStatus.scheduled,
                          ),
                        );
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Double booking detected for selected time slot.')),
                    );
                    return;
                  }

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment added successfully.')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showPatientFormDialog(
  BuildContext context,
  WidgetRef ref, {
  Patient? initial,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: initial?.name ?? '');
  final ageController = TextEditingController(text: initial?.age.toString() ?? '');
  final phoneController = TextEditingController(text: initial?.phone ?? '');
  final issueController = TextEditingController(text: initial?.medicalHistory ?? '');

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initial == null ? 'Add Patient' : 'Edit Patient'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Name',
                controller: nameController,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Age',
                controller: ageController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final age = int.tryParse(v ?? '');
                  if (age == null || age <= 0) return 'Valid age is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Phone',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 8) ? 'Valid phone is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Dental Issue',
                controller: issueController,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Dental issue is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            // Generate email for new patients if not provided
            String? patientEmail = initial?.email;
            if (initial == null && (patientEmail == null || patientEmail.isEmpty)) {
              final name = nameController.text.trim().toLowerCase();
              final nameParts = name.split(' ');
              if (nameParts.isNotEmpty) {
                final firstName = nameParts.first;
                final lastName = nameParts.length > 1 ? nameParts.last : '';
                patientEmail = lastName.isNotEmpty
                    ? '$firstName.$lastName@dentalclinic.com'
                    : '$firstName@dentalclinic.com';
              }
            }

            final payload = Patient(
              id: initial?.id,
              name: nameController.text.trim(),
              phone: phoneController.text.trim(),
              age: int.parse(ageController.text.trim()),
              gender: initial?.gender ?? 'Other',
              medicalHistory: issueController.text.trim(),
              createdAt: initial?.createdAt,
              email: patientEmail,
              address: initial?.address,
              emergencyContact: initial?.emergencyContact,
            );

            if (initial == null) {
              await ref.read(patientListProvider.notifier).addPatient(payload);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patient added successfully.')),
                );
              }
            } else {
              await ref.read(patientListProvider.notifier).updatePatient(payload);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patient updated successfully.')),
                );
              }
            }

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void _showPatientDetailsDialog(BuildContext context, WidgetRef ref, Patient patient) {
  final payments = ref.read(paymentProvider.notifier).byPatientId(patient.id);
  final report = ref.read(reportProvider.notifier).reportForPatient(patient.id);
  final completedPreviousAppointments = ref
      .read(appointmentProvider)
      .where(
        (a) =>
            a.patientId == patient.id &&
            a.status == AppointmentStatus.completed &&
            a.appointmentDate.isBefore(DateTime.now()),
      )
      .toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(patient.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Age: ${patient.age}'),
            const SizedBox(height: 4),
            Text('Phone: ${patient.phone}'),
            const SizedBox(height: 4),
            Text('Dental issue: ${patient.medicalHistory}'),
            const SizedBox(height: 12),
            Text(
              'Billing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text('Total: ₹${payments.total.toStringAsFixed(2)}'),
            Text(
              'Paid: ₹${payments.paid.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.successColor),
            ),
            Text(
              'Remaining: ₹${payments.remaining.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.errorColor),
            ),
            const SizedBox(height: 12),
            if (report != null) ...[
              Text('Latest Report', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Diagnosis: ${report.diagnosis}'),
              Text('Treatment: ${report.treatment}'),
            ],
            const SizedBox(height: 12),
            Text(
              'Completed Previous Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            if (completedPreviousAppointments.isEmpty)
              const Text('No completed previous appointments yet.')
            else
              ...completedPreviousAppointments.map(
                (apt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${apt.appointmentDate.day}/${apt.appointmentDate.month}/${apt.appointmentDate.year} • ${apt.startTime.hour.toString().padLeft(2, '0')}:${apt.startTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showPaymentUpdateDialog(context, ref, patient.id, payments);
          },
          child: const Text('Update Payment'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showPatientFormDialog(context, ref, initial: patient);
          },
          child: const Text('Edit'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showPaymentUpdateDialog(
  BuildContext context,
  WidgetRef ref,
  String patientId,
  PaymentSummary current,
) async {
  final formKey = GlobalKey<FormState>();
  final totalController = TextEditingController(text: current.total.toStringAsFixed(0));
  final paidController = TextEditingController(text: current.paid.toStringAsFixed(0));

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update Payment'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Total Amount (₹)',
              controller: totalController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount < 0) return 'Enter valid total amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Paid Amount (₹)',
              controller: paidController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount < 0) return 'Enter valid paid amount';
                final total = double.tryParse(totalController.text) ?? 0;
                if (amount > total) return 'Paid amount cannot exceed total amount';
                return null;
              },
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
            if (!formKey.currentState!.validate()) return;

            final total = double.parse(totalController.text.trim());
            final paid = double.parse(paidController.text.trim());
            await ref.read(paymentProvider.notifier).upsertPayment(
                  PaymentSummary(patientId: patientId, total: total, paid: paid),
                );

            final patients = ref.read(patientListProvider);
            final target = patients.where((p) => p.id == patientId).toList();
            if (target.isNotEmpty) {
              await ref.read(patientListProvider.notifier).updatePatient(
                    target.first.copyWith(
                      totalAmount: total,
                      paidAmount: paid,
                    ),
                  );
            }

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment updated successfully.')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _showDoctorEditDialog(
  BuildContext context,
  WidgetRef ref,
  DoctorProfile doctor,
) async {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: doctor.name);
  final qualification = TextEditingController(text: doctor.qualification);
  final specialization = TextEditingController(text: doctor.specialization);
  final phone = TextEditingController(text: doctor.phone);
  final email = TextEditingController(text: doctor.email);
  final address = TextEditingController(text: doctor.clinicAddress);

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Name',
                controller: name,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Qualification',
                controller: qualification,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Qualification is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Specialization',
                controller: specialization,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Specialization is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Phone',
                controller: phone,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Email',
                controller: email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Clinic Address',
                controller: address,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            await ref.read(doctorProvider.notifier).updateProfile(
                  doctor.copyWith(
                    name: name.text.trim(),
                    qualification: qualification.text.trim(),
                    specialization: specialization.text.trim(),
                    phone: phone.text.trim(),
                    email: email.text.trim(),
                    clinicAddress: address.text.trim(),
                  ),
                );
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Doctor profile updated.')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
