import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/phone_utils.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String phone;
  final String? initialOtp;

  const VerifyPhoneScreen({
    super.key,
    required this.phone,
    this.initialOtp,
  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialOtp != null && widget.initialOtp!.isNotEmpty) {
      _otpController.text = widget.initialOtp!;
    }
  }

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
    final success = await auth.verifyPhone(widget.phone, otp);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone verified successfully! You can now log in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Phone verification failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final formattedPhone = PhoneUtils.formatIndianPhoneNumber(widget.phone);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
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
                  Icons.phone_android_rounded,
                  size: 48,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Phone Number',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit verification code to $formattedPhone',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              if (widget.initialOtp != null && widget.initialOtp!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Dev OTP Auto-filled: ${widget.initialOtp}',
                          style: const TextStyle(fontSize: 13, color: Colors.amberAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                          'VERIFY PHONE',
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
