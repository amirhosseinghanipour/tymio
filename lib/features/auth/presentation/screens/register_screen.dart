import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employerIdController = TextEditingController();
  bool _isEmployer = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _employerIdController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _isEmployer ? 'employer' : 'employee',
        employerId: _isEmployer ? null : _employerIdController.text.trim(),
      );
      // On success, the authStateChanges stream will trigger navigation in Main wrapper
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Tymio to manage attendance',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) => Validators.minLength(val, 6),
                ),
                const SizedBox(height: 24),
                
                // Role Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I am a...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Employee Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isEmployer = false),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: !_isEmployer ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_isEmployer ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3),
                                  width: !_isEmployer ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    SolarIconsOutline.user,
                                    size: 32,
                                    color: !_isEmployer ? Colors.white : AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Employee',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: !_isEmployer ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Track my attendance',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: !_isEmployer ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Employer Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isEmployer = true),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _isEmployer ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isEmployer ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3),
                                  width: _isEmployer ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    SolarIconsOutline.home,
                                    size: 32,
                                    color: _isEmployer ? Colors.white : AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Employer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _isEmployer ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage my team',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isEmployer ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_isEmployer) ...[
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Employer Code',
                        controller: _employerIdController,
                        hint: 'Enter your employer\'s ID',
                        validator: _isEmployer ? null : Validators.required,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: 'Register',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
