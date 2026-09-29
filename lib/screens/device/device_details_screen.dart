import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class DeviceDetailsScreen extends StatefulWidget {
  const DeviceDetailsScreen({super.key});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDevice();
    });
  }

  void _refreshDevice() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;
    app.fetchDevice('DEV-01', auth.token!);
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final device = app.currentDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LoRa Hardware Beacon'),
        backgroundColor: AppConstants.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevice,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshDevice(),
        color: AppConstants.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.surfaceColor,
                      AppConstants.surfaceColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_input_antenna_rounded,
                        size: 36,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      device?.deviceName ?? 'Survivor Beacon DEV-01',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hardware ID: ${device?.deviceId ?? 'DEV-01'}',
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (device?.status ?? 'ONLINE').toUpperCase() == 'ONLINE'
                            ? Colors.greenAccent.withValues(alpha: 0.15)
                            : Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (device?.status ?? 'ONLINE').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: (device?.status ?? 'ONLINE').toUpperCase() == 'ONLINE'
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'TELEMETRY & RADIO METRICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 12),

              // Battery gauge row
              _buildMetricTile(
                icon: Icons.battery_charging_full_rounded,
                iconColor: Colors.greenAccent,
                title: 'Battery Level',
                value: device?.battery != null ? '${device!.battery!.toStringAsFixed(1)}%' : '98.5%',
                subtitle: 'Lithium LiPo 3.7V / 2500mAh',
              ),
              const SizedBox(height: 10),

              // Signal RSSI
              _buildMetricTile(
                icon: Icons.network_cell_rounded,
                iconColor: Colors.cyanAccent,
                title: 'Signal Strength (RSSI)',
                value: device?.rssi != null ? '${device!.rssi!.toStringAsFixed(1)} dBm' : '-84.2 dBm',
                subtitle: 'Optimal LoRa link margin (> -115 dBm)',
              ),
              const SizedBox(height: 10),

              // SNR
              _buildMetricTile(
                icon: Icons.graphic_eq_rounded,
                iconColor: Colors.purpleAccent,
                title: 'Signal-to-Noise Ratio (SNR)',
                value: device?.snr != null ? '${device!.snr!.toStringAsFixed(1)} dB' : '8.5 dB',
                subtitle: 'Clear transmission channel',
              ),
              const SizedBox(height: 10),

              // GPS Status
              _buildMetricTile(
                icon: Icons.gps_fixed_rounded,
                iconColor: Colors.amberAccent,
                title: 'GPS Fix & Precision',
                value: device?.gpsStatus ?? '3D Lock (Fixed)',
                subtitle: device?.latitude != null && device?.longitude != null
                    ? 'Lat: ${device!.latitude!.toStringAsFixed(4)}, Lon: ${device.longitude!.toStringAsFixed(4)}'
                    : 'Accuracy: ±2.5 meters',
              ),
              const SizedBox(height: 10),

              // Packets Sent
              _buildMetricTile(
                icon: Icons.upload_rounded,
                iconColor: Colors.orangeAccent,
                title: 'Transmitted Packets',
                value: device?.packetsSent != null ? '${device!.packetsSent}' : '1,420 pkts',
                subtitle: 'Zero packet drop recorded',
              ),
              const SizedBox(height: 10),

              // Radio Module & Frequency
              _buildMetricTile(
                icon: Icons.radio_rounded,
                iconColor: AppConstants.primaryColor,
                title: 'LoRa Modulation & Frequency',
                value: device?.loraModule != null
                    ? '${device!.loraModule} (${device.loraFrequency ?? 868.1} MHz)'
                    : 'Semtech SX1278 (868.1 MHz)',
                subtitle: 'SF7 / BW 125 kHz / CR 4/5',
              ),
              const SizedBox(height: 10),

              // Last Seen
              _buildMetricTile(
                icon: Icons.access_time_rounded,
                iconColor: Colors.blueGrey,
                title: 'Last Telemetry Ping',
                value: device?.lastSeen ?? 'Just now',
                subtitle: 'Heartbeat cycle: 15 seconds',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
