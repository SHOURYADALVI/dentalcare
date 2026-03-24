import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../core/providers/treatment_providers.dart';
import '../../../../core/providers/patient_providers.dart';
import '../../../../models/treatment.dart';
import '../../../../widgets/buttons.dart';
import '../../../../widgets/form_fields.dart';

class TreatmentsPage extends ConsumerStatefulWidget {
  const TreatmentsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TreatmentsPage> createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends ConsumerState<TreatmentsPage> {
  bool _showAddForm = false;

  @override
  Widget build(BuildContext context) {
    final treatmentsAsync = ref.watch(treatmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Treatment Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAddForm = !_showAddForm;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),

            if (_showAddForm)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: _AddTreatmentForm(
                    onComplete: () {
                      setState(() {
                        _showAddForm = false;
                      });
                    },
                  ),
                ),
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
                              Icons.medical_services,
                              size: 48,
                              color: AppTheme.dividerColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No treatments recorded',
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
                      .map((treatment) => Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppTheme.paddingMedium,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              treatment.patientName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              treatment.procedure,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${treatment.cost.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: AppTheme
                                                      .accentColor,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${treatment.treatmentDate.day}/${treatment.treatmentDate.month}/${treatment.treatmentDate.year}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Text(
                                    'Diagnosis: ${treatment.diagnosis}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  if (treatment.notes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        'Notes: ${treatment.notes}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
                    child: Text('Error loading treatments: $error'),
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

class _AddTreatmentForm extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const _AddTreatmentForm({required this.onComplete});

  @override
  ConsumerState<_AddTreatmentForm> createState() =>
      _AddTreatmentFormState();
}

class _AddTreatmentFormState extends ConsumerState<_AddTreatmentForm> {
  String? _selectedPatientId;
  final _diagnosisController = TextEditingController();
  final _procedureController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _treatmentDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _procedureController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveTreatment() async {
    if (_selectedPatientId == null || _treatmentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final patient = ref
          .read(patientsProvider)
          .value
          ?.firstWhere((p) => p.id == _selectedPatientId);

      final treatment = Treatment(
        patientId: _selectedPatientId!,
        patientName: patient?.name ?? '',
        treatmentDate: _treatmentDate!,
        diagnosis: _diagnosisController.text,
        procedure: _procedureController.text,
        cost: double.parse(_costController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await ref.read(addTreatmentProvider(treatment).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment recorded successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient dropdown
        patientsAsync.when(
          data: (patients) {
            return CustomDropdownField<String>(
              label: 'Patient',
              value: _selectedPatientId,
              items: patients
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatientId = value;
                });
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const Text('Error loading patients'),
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // Treatment date
        DatePickerField(
          label: 'Treatment Date',
          value: _treatmentDate,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() => _treatmentDate = date);
            }
          },
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // Diagnosis
        CustomTextField(
          label: 'Diagnosis',
          hint: 'Enter diagnosis',
          controller: _diagnosisController,
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // Procedure
        CustomTextField(
          label: 'Procedure',
          hint: 'Enter procedure',
          controller: _procedureController,
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // Cost
        CustomTextField(
          label: 'Cost',
          hint: 'Enter cost',
          controller: _costController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTheme.paddingMedium),

        // Notes
        CustomTextField(
          label: 'Notes (Optional)',
          hint: 'Enter notes',
          controller: _notesController,
          maxLines: 3,
        ),
        const SizedBox(height: AppTheme.paddingLarge),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Cancel',
                onPressed: widget.onComplete,
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: PrimaryButton(
                label: 'Save',
                isLoading: _isLoading,
                onPressed: _saveTreatment,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
