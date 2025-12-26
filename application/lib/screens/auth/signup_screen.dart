import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _ageController = TextEditingController();
  final _specializationController = TextEditingController();

  UserRole _selectedRole = UserRole.patient;
  String _selectedGender = 'male';
  String _selectedBloodGroup = 'O+';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _bloodGroups = [
    'A+','A-','B+','B-','AB+','AB-','O+','O-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final auth = context.read<AuthProvider>();

      final message = await auth.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        gender: _selectedGender,
        age: _selectedRole == UserRole.patient
            ? int.parse(_ageController.text)
            : null,
        bloodGroup:
            _selectedRole == UserRole.patient ? _selectedBloodGroup : null,
        specialization:
            _selectedRole == UserRole.doctor ? _specializationController.text : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.health_and_safety,
                      size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text('Create Account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 32),

                  _textField(_nameController, 'Full Name', Icons.person),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Register as',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRole = value!),
                  ),
                  const SizedBox(height: 16),

                  // Gender (patient, doctor, caregiver)
                  if (_selectedRole != UserRole.admin)
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),

                  if (_selectedRole != UserRole.admin)
                    const SizedBox(height: 16),

                  // Patient-only
                  if (_selectedRole == UserRole.patient) ...[
                    _textField(
                      _ageController,
                      'Age',
                      Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group',
                        prefixIcon: Icon(Icons.bloodtype),
                        border: OutlineInputBorder(),
                      ),
                      items: _bloodGroups
                          .map((bg) =>
                              DropdownMenuItem(value: bg, child: Text(bg)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedBloodGroup = v!),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Doctor-only
                  if (_selectedRole == UserRole.doctor) ...[
                    _textField(
                      _specializationController,
                      'Specialization',
                      Icons.medical_information,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _textField(_emailController, 'Email', Icons.email,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  _passwordField(
                    controller: _passwordController,
                    label: 'Password',
                    visible: _isPasswordVisible,
                    onToggle: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  const SizedBox(height: 16),

                  _passwordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    visible: _isConfirmPasswordVisible,
                    onToggle: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible),
                    confirmAgainst: _passwordController.text,
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleSignup,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text('Sign Up'),
                  ),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    String? confirmAgainst,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (confirmAgainst != null && v != confirmAgainst) {
          return 'Passwords do not match';
        }
        if (v.length < 6) return 'Min 6 characters';
        return null;
      },
    );
  }
}
