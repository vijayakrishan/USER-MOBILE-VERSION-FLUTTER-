import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/sos_status_card.dart';
import '../../widgets/device_status_card.dart';
import '../../widgets/stat_card.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _emergencyDetailsController = TextEditingController();
  String _selectedPriority = 'HIGH';
  String _selectedCategory = 'Medical Emergency';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDashboardData();
    });
  }

  void _initDashboardData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final userId = auth.userId!;
    final token = auth.token!;

    app.updateLocation();
    app.fetchSosHistory(userId, token);
    app.fetchDevice('DEV-01', token);

    // Profile lookup using actual user UUID or email
    final identifier = auth.userId ?? auth.email;
    if (identifier != null) {
      app.fetchUserProfile(identifier, token);
    }

    app.startPolling(userId: userId, token: token, deviceId: 'DEV-01');
  }

  @override
  void dispose() {
    _emergencyDetailsController.dispose();
    super.dispose();
  }

  void _showSosConfirmationDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    _emergencyDetailsController.text = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.warning_rounded, color: Color(0xFFFF2E63), size: 28),
                        SizedBox(width: 10),
                        Text(
                          'CONFIRM DISTRESS SIGNAL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your coordinates and LoRa node telemetry will be broadcasted to nearest rescue squads.',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                    const SizedBox(height: 16),

                    // Quick category pills
                    const Text(
                      'Emergency Type',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Medical Emergency',
                        'Trapped / Flood',
                        'Structural Collapse',
                        'Fire Hazard',
                      ].map((type) {
                        final isSelected = _selectedCategory == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (val) {
                            setModalState(() => _selectedCategory = type);
                          },
                          selectedColor: AppConstants.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Priority selector
                    const Text(
                      'Urgency Level',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['CRITICAL', 'HIGH', 'MEDIUM'].map((priority) {
                        final isSelected = _selectedPriority == priority;
                        Color pColor = Colors.orange;
                        if (priority == 'CRITICAL') pColor = Colors.red;
                        if (priority == 'MEDIUM') pColor = Colors.blue;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() => _selectedPriority = priority);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? pColor.withValues(alpha: 0.25) : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected ? pColor : Colors.white24,
                                  width: isSelected ? 2 : 1,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                priority,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? pColor : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Emergency details textfield
                    TextField(
                      controller: _emergencyDetailsController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Situation Details (Optional)',
                        hintText: 'e.g. 2 people stranded on rooftop, water rising',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: AppConstants.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Coordinates banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: AppConstants.primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            app.currentPosition != null
                                ? 'GPS: ${app.currentPosition!.latitude.toStringAsFixed(4)}, ${app.currentPosition!.longitude.toStringAsFixed(4)}'
                                : 'Acquiring GPS location...',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(ctx);

                              final details = _emergencyDetailsController.text.trim().isNotEmpty
                                  ? '[$_selectedCategory] ${_emergencyDetailsController.text.trim()}'
                                  : '[$_selectedCategory] Emergency rescue needed immediately.';

                              final victimName = app.userProfile?.name ??
                                  auth.name ??
                                  (auth.email != null ? auth.email!.split('@')[0] : 'Survivor');

                              final victimContact = app.userProfile?.phone ?? auth.phone ?? '';

                              final success = await app.triggerSos(
                                userId: auth.userId!,
                                email: auth.email,
                                token: auth.token!,
                                victimName: victimName,
                                victimContact: victimContact,
                                details: details,
                                priority: _selectedPriority,
                                deviceId: 'DEV-01',
                              );

                              if (!mounted) return;

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Distress beacon dispatched! Assigned rescue units notified.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(app.errorMessage ?? 'Failed to dispatch SOS'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF2E63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'DISPATCH SIGNAL',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCancelSos(String sosId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text('Cancel Distress Signal?'),
        content: const Text(
          'Are you sure you want to stand down this emergency alert? Rescue teams will be notified.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('NO, KEEP ACTIVE', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('YES, CANCEL SOS'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    if (!auth.isAuthenticated) return;

    final success = await app.cancelSos(
      sosId,
      auth.token!,
      auth.userId!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Distress signal stood down.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);

    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeSos = app.activeSos;
    final device = app.currentDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppConstants.primaryColor, size: 22),
            SizedBox(width: 8),
            Text('ResQMesh Survivor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: AppConstants.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (auth.isAuthenticated) {
                app.updateLocation();
                app.fetchSosHistory(auth.userId!, auth.token!);
                app.fetchDevice('DEV-01', auth.token!);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${app.userProfile?.name ?? auth.name ?? (auth.email?.split('@')[0] ?? 'Survivor')}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${auth.userId?.substring(0, 8)}... | LoRa Link',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 14),
                        SizedBox(width: 4),
                        Text('NETWORK ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // KPI Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'DEVICE',
                      value: device != null && (device.status ?? '').toUpperCase() == 'ONLINE'
                          ? 'ONLINE'
                          : 'STANDBY',
                      icon: Icons.router,
                      iconColor: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'BATTERY',
                      value: device?.battery != null ? '${device!.battery!.toStringAsFixed(0)}%' : '100%',
                      icon: Icons.battery_charging_full,
                      iconColor: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'SIGNAL',
                      value: device?.rssi != null ? '${device!.rssi!.toStringAsFixed(0)} dBm' : '-85 dBm',
                      icon: Icons.wifi,
                      iconColor: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'SYS HEALTH',
                      value: 'GOOD',
                      icon: Icons.health_and_safety,
                      iconColor: Colors.greenAccent,
                      isHealth: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active SOS Card (if in progress)
              if (activeSos != null) ...[
                SosStatusCard(
                  alert: activeSos,
                  isCancelling: app.isLoading,
                  onCancel: () => _handleCancelSos(activeSos.id!),
                ),
                const SizedBox(height: 24),
              ],

              // Central Emergency Trigger Zone
              Center(
                child: Column(
                  children: [
                    SosButton(
                      isLoading: app.isLoading,
                      status: activeSos != null ? (activeSos.status ?? 'ACTIVE') : 'IDLE',
                      onPressed: () {
                        if (activeSos != null) {
                          _handleCancelSos(activeSos.id!);
                        } else {
                          _showSosConfirmationDialog();
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      activeSos != null
                          ? 'Tap above to stand down active distress signal'
                          : 'Tap for immediate rescue team dispatch',
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Hardware Registry Telemetry Card
              const Text(
                'Linked LoRa Hardware',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              DeviceStatusCard(
                device: device,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
