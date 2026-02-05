import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
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
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                const Text(
                  'Join Tymio to manage attendance',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: Validators.required,
                  prefixIcon: const Icon(SolarIconsOutline.user),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(SolarIconsOutline.letter),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) => Validators.minLength(val, 6),
                  prefixIcon: const Icon(SolarIconsOutline.lockPassword),
                ),
                const SizedBox(height: 24),
                
                // Role Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(SolarIconsOutline.usersGroupTwoRounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isEmployer ? 'I am an Employer' : 'I am an Employee',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Switch(
                            value: _isEmployer,
                            onChanged: (val) {
                              setState(() {
                                _isEmployer = val;
                              });
                            },
                          ),
                        ],
                      ),
                      if (!_isEmployer) ...[
                        const Divider(height: 24),
                        CustomTextField(
                          label: 'Employer Code',
                          controller: _employerIdController,
                          hint: 'Enter your employer\'s ID',
                          validator: _isEmployer ? null : Validators.required,
                          prefixIcon: const Icon(SolarIconsOutline.key),
                        ),
                      ],
                    ],
                  ),
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
