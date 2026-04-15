import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../widgets/buttons.dart';
import '../../../../widgets/form_fields.dart';
import '../../../../core/theme.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../models/user_role.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.patient;
  String? _selectedPatientEmail;

  @override
  void initState() {
    super.initState();
    final patientUsers = ref.read(demoPatientUsersProvider);
    if (patientUsers.isNotEmpty) {
      _selectedPatientEmail = patientUsers.first.email;
      _emailController.text = _selectedPatientEmail!;
    } else {
      _emailController.text = '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(
        loginProvider((_emailController.text.trim(), _passwordController.text)).future,
      );

      if (mounted) {
        if (success) {
          final role = ref.read(currentUserProvider)?.role;
          if (role == UserRole.patient) {
            context.push('/patient');
          } else if (role == UserRole.dentist) {
            context.push('/doctor');
          } else {
            context.push('/receptionist');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        Text(
                          'DENTLINK',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Secure role-based access',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Role',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<UserRole>(
                          segments: const [
                            ButtonSegment(
                              value: UserRole.patient,
                              label: Text('Patient'),
                              icon: Icon(Icons.person_outline),
                            ),
                            ButtonSegment(
                              value: UserRole.dentist,
                              label: Text('Dentist'),
                              icon: Icon(Icons.medical_information),
                            ),
                            ButtonSegment(
                              value: UserRole.receptionist,
                              label: Text('Receptionist'),
                              icon: Icon(Icons.support_agent),
                            ),
                          ],
                          selected: {_selectedRole},
                          onSelectionChanged: (newSelection) {
                            final selected = newSelection.first;
                            setState(() {
                              _selectedRole = selected;
                              if (selected == UserRole.patient) {
                                final patientUsers = ref.read(demoPatientUsersProvider);
                                _selectedPatientEmail = patientUsers.isNotEmpty
                                    ? patientUsers.first.email
                                    : null;
                                _emailController.text = _selectedPatientEmail ?? '';
                              } else if (selected == UserRole.dentist) {
                                _emailController.text = 'dentist@dental.com';
                              } else {
                                _emailController.text = 'receptionist@dental.com';
                              }
                            });
                          },
                        ),
                        if (_selectedRole == UserRole.patient) ...[
                          const SizedBox(height: AppTheme.paddingMedium),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedPatientEmail,
                            items: ref
                                .watch(demoPatientUsersProvider)
                                .map(
                                  (user) => DropdownMenuItem<String>(
                                    value: user.email,
                                    child: Text(
                                      '${user.name} (${user.email})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPatientEmail = value;
                                _emailController.text = value ?? '';
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Patient Account',
                              prefixIcon: Icon(Icons.person_search_outlined),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.paddingLarge),
                        CustomTextField(
                          label: 'Email',
                          hint: 'Select account above',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter any password',
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        PrimaryButton(
                          label: 'Login to Dashboard',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          child: Text(
                            'Select a role and account above.\nPassword can be any value for demo.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
