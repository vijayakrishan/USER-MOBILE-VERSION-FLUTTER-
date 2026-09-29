import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyEmail(widget.email, otp);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Email verification failed'),
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
        title: const Text('Email Verification'),
        backgroundColor: AppConstants.backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 48,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Email Address',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to ${widget.email}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    letterSpacing: 12,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      : const Text(
                          'VERIFY EMAIL',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
