import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0; // 0: Request OTP, 1: Verify OTP, 2: Reset Password

  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email or phone number')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.requestPasswordReset(identifier);

    if (!mounted) return;

    if (success) {
      setState(() => _currentStep = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset OTP sent successfully! Check your email or SMS.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to send reset OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final identifier = _identifierController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyPasswordResetOtp(identifier, otp);

    if (!mounted) return;

    if (success) {
      setState(() => _currentStep = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified! Please set your new password.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Invalid or expired OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    final identifier = _identifierController.text.trim();
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.resetPassword(identifier, newPass);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please login with your new password.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to reset password'),
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
        title: const Text('Reset Password'),
        backgroundColor: AppConstants.backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper indicator
              Row(
                children: [
                  _buildStepIndicator(0, '1. Identifier'),
                  _buildStepDivider(0),
                  _buildStepIndicator(1, '2. OTP'),
                  _buildStepDivider(1),
                  _buildStepIndicator(2, '3. Reset'),
                ],
              ),
              const SizedBox(height: 32),

              // Step 0: Request OTP
              if (_currentStep == 0) ...[
                const Text(
                  'Account Recovery',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your registered email address or phone number to receive a verification code.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _identifierController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email or Phone Number',
                    prefixIcon: const Icon(Icons.person_outline, color: AppConstants.primaryColor),
                    filled: true,
                    fillColor: AppConstants.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRequestOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : const Text('SEND VERIFICATION CODE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],

              // Step 1: Verify OTP
              if (_currentStep == 1) ...[
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to ${_identifierController.text.trim()}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    filled: true,
                    fillColor: AppConstants.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : const Text('VERIFY CODE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    child: const Text('Change Email or Phone', style: TextStyle(color: Colors.white54)),
                  ),
                ),
              ],

              // Step 2: New Password
              if (_currentStep == 2) ...[
                const Text(
                  'Create New Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a strong password with at least 6 characters.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'New Password',
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
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
                    filled: true,
                    fillColor: AppConstants.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : const Text('RESET PASSWORD', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final bool isCompleted = _currentStep > step;
    final bool isCurrent = _currentStep == step;

    Color color = Colors.white24;
    if (isCompleted || isCurrent) {
      color = AppConstants.primaryColor;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppConstants.primaryColor : Colors.transparent,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : Colors.white54,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.white : Colors.white54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(int step) {
    final bool isCompleted = _currentStep > step;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isCompleted ? AppConstants.primaryColor : Colors.white24,
    );
  }
}
