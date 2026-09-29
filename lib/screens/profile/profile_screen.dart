import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user_profile.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _medicalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _relationshipController.dispose();
    _medicalInfoController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    if (!auth.isAuthenticated) return;

    final identifier = auth.userId ?? auth.email!;
    final token = auth.token!;

    app.fetchUserProfile(identifier, token).then((_) {
      final p = app.userProfile;
      if (p != null && mounted) {
        setState(() {
          _nameController.text = p.name ?? '';
          _phoneController.text = p.phone ?? '';
          _dobController.text = p.dateOfBirth ?? '';
          _genderController.text = p.gender ?? '';
          _addressController.text = p.address ?? '';
          _emergencyNameController.text = p.emergencyContactName ?? '';
          _emergencyPhoneController.text = p.emergencyContactNumber ?? '';
          _relationshipController.text = p.relationship ?? '';
          _medicalInfoController.text = p.medicalInformation ?? '';
        });
      }
    });
  }

  Future<void> _handleSaveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    if (!auth.isAuthenticated) return;

    final identifier = auth.userId ?? auth.email!;
    final token = auth.token!;

    final updatedProfile = UserProfile(
      id: auth.userId,
      email: auth.email,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _genderController.text.trim(),
      address: _addressController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactNumber: _emergencyPhoneController.text.trim(),
      relationship: _relationshipController.text.trim(),
      medicalInformation: _medicalInfoController.text.trim(),
    );

    final success = await app.updateUserProfile(identifier, updatedProfile, token);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to sign out from ResQMesh?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    app.stopPolling();
    await auth.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survivor Profile'),
        backgroundColor: AppConstants.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar Banner
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        (auth.email?.isNotEmpty ?? false) ? auth.email![0].toUpperCase() : 'S',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      auth.email ?? 'survivor@resqmesh.org',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'ROLE: USER / SURVIVOR',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Personal Info
              _buildSectionHeader(Icons.person_outline, 'PERSONAL INFORMATION'),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Mobile Phone', Icons.phone),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)', Icons.cake_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_genderController, 'Gender', Icons.wc_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_addressController, 'Residential Address', Icons.home_outlined, maxLines: 2),
              const SizedBox(height: 24),

              // Section 2: Emergency Contact
              _buildSectionHeader(Icons.contact_phone_outlined, 'EMERGENCY CONTACT'),
              const SizedBox(height: 12),
              _buildTextField(_emergencyNameController, 'Contact Person Name', Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildTextField(_emergencyPhoneController, 'Emergency Phone Number', Icons.phone_in_talk_outlined),
              const SizedBox(height: 12),
              _buildTextField(_relationshipController, 'Relationship (e.g. Spouse, Parent)', Icons.family_restroom_outlined),
              const SizedBox(height: 24),

              // Section 3: Medical Notes
              _buildSectionHeader(Icons.medical_services_outlined, 'MEDICAL INFORMATION'),
              const SizedBox(height: 12),
              _buildTextField(
                _medicalInfoController,
                'Allergies, Blood Group, Medical Conditions',
                Icons.health_and_safety_outlined,
                maxLines: 3,
                hintText: 'e.g. Blood Group O+, Asthma, Penicillin allergy',
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: app.isLoading ? null : _handleSaveProfile,
                  icon: app.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    app.isLoading ? 'SAVING...' : 'SAVE CHANGES',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: AppConstants.surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
