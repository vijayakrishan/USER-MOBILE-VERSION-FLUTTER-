import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/register_request.dart';
import '../../utils/constants.dart';
import 'verify_phone_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile phone number')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final req = RegisterRequest(
      name: name,
      phone: phone,
      email: email.isNotEmpty ? email : null,
      password: password,
    );

    final responseText = await auth.register(req);

    if (!mounted) return;

    if (responseText != null) {
      // Extract OTP from response message if available (e.g. "Phone OTP: 123456")
      String? extractedOtp;
      final otpRegex = RegExp(r'Phone OTP:\s*(\d{6})');
      final match = otpRegex.firstMatch(responseText);
      if (match != null) {
        extractedOtp = match.group(1);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please verify your phone number.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to phone verification
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyPhoneScreen(
            phone: phone,
            initialOtp: extractedOtp,
          ),
        ),
      );

      if (!mounted) return;

      if (verified == true) {
        Navigator.pop(context); // Go back to login
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survivor Registration'),
        backgroundColor: AppConstants.backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Register to access emergency dispatch & offline LoRa beacons.',
                style: TextStyle(fontSize: 13, color: Colors.white54),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person_outline, color: AppConstants.primaryColor),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Phone Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number (Required for OTP) *',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppConstants.primaryColor),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address (Optional)',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppConstants.primaryColor),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password (min 6 characters) *',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 28),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      : const Text(
                          'REGISTER & GET OTP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
