import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../widgets/buttons.dart';
import '../../../../widgets/form_fields.dart';
import '../../../../core/theme.dart';
import '../../../../core/providers/clinic_crud_providers.dart';
import '../../../../models/patient.dart';

class AddEditPatientPage extends ConsumerStatefulWidget {
  final String? patientId;

  const AddEditPatientPage({
    Key? key,
    this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<AddEditPatientPage> createState() =>
      _AddEditPatientPageState();
}

class _AddEditPatientPageState extends ConsumerState<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  String? _selectedGender = 'Male';
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _loadPatientData();
    }
  }

  void _loadPatientData() {
    final patients = ref.read(patientListProvider);
    Patient? patient;
    try {
      patient = patients.firstWhere((p) => p.id == widget.patientId);
    } catch (_) {
      patient = null;
    }
    if (patient != null && mounted) {
      final patientGender = patient.gender;
      _nameController.text = patient.name;
      _phoneController.text = patient.phone;
      _ageController.text = patient.age.toString();
      _emailController.text = patient.email ?? '';
      _addressController.text = patient.address ?? '';
      _medicalHistoryController.text = patient.medicalHistory;
      _emergencyContactController.text = patient.emergencyContact ?? '';
      setState(() {
        _selectedGender = patientGender;
        _isInit = true;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Patient? existing;
      if (widget.patientId != null) {
        final current = ref.read(patientListProvider);
        final matches = current.where((p) => p.id == widget.patientId).toList();
        existing = matches.isNotEmpty ? matches.first : null;
      }

      final patient = widget.patientId == null
          ? Patient(
              name: _nameController.text,
              phone: _phoneController.text,
              age: int.parse(_ageController.text),
              gender: _selectedGender!,
              medicalHistory: _medicalHistoryController.text,
              address: _addressController.text,
              email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
              emergencyContact: _emergencyContactController.text.isEmpty
                  ? null
                  : _emergencyContactController.text,
            )
          : Patient(
              id: widget.patientId,
              name: _nameController.text,
              phone: _phoneController.text,
              age: int.parse(_ageController.text),
              gender: _selectedGender!,
              medicalHistory: _medicalHistoryController.text,
              totalAmount: existing?.totalAmount,
              paidAmount: existing?.paidAmount,
              createdAt: existing?.createdAt,
              address: _addressController.text,
              email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
              emergencyContact: _emergencyContactController.text.isEmpty
                  ? null
                  : _emergencyContactController.text,
            );

      if (widget.patientId == null) {
        await ref.read(patientListProvider.notifier).addPatient(patient);
      } else {
        await ref.read(patientListProvider.notifier).updatePatient(patient);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.patientId == null
                ? 'Patient added successfully'
                : 'Patient updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patientId == null ? 'Add Patient' : 'Edit Patient',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter patient name',
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Phone
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Phone is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Age and Gender
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Age',
                      hint: 'Enter age',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Age is required';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: CustomDropdownField<String>(
                      label: 'Gender',
                      value: _selectedGender,
                      items: ['Male', 'Female', 'Other']
                          .map((gender) =>
                              DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Email
              CustomTextField(
                label: 'Email (Optional)',
                hint: 'Enter email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Address
              CustomTextField(
                label: 'Address (Optional)',
                hint: 'Enter address',
                controller: _addressController,
                maxLines: 2,
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Medical History
              CustomTextField(
                label: 'Medical History',
                hint: 'Enter medical history',
                controller: _medicalHistoryController,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Medical history is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Emergency Contact
              CustomTextField(
                label: 'Emergency Contact (Optional)',
                hint: 'Enter emergency contact',
                controller: _emergencyContactController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: PrimaryButton(
                      label: widget.patientId == null ? 'Add Patient' : 'Update Patient',
                      isLoading: _isLoading,
                      onPressed: _savePatient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
