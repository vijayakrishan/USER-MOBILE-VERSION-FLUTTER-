import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'verify_phone_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email/phone and password')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(identifier, password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final error = auth.errorMessage ?? 'Login failed';
      if (error.contains('ACCOUNT_NOT_VERIFIED')) {
        _showUnverifiedAccountDialog(identifier);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showUnverifiedAccountDialog(String identifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
            SizedBox(width: 8),
            Text('Account Not Verified'),
          ],
        ),
        content: const Text(
          'Your account is pending verification. Please verify your phone number to activate your account.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VerifyPhoneScreen(phone: identifier),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
            child: const Text('Verify Phone'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ResQMesh Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppConstants.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 52,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'RESQMESH',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Disaster Rescue & Survivor Portal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 36),

                // Identifier Field
                TextField(
                  controller: _identifierController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email or Mobile Number',
                    prefixIcon: const Icon(Icons.person_outline, color: AppConstants.primaryColor),
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
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                const SizedBox(height: 10),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppConstants.primaryColor, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register as Survivor',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
