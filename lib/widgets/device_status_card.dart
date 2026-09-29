import 'package:flutter/material.dart';
import '../models/device_response.dart';
import '../utils/constants.dart';

class DeviceStatusCard extends StatelessWidget {
  final DeviceResponse? device;
  final VoidCallback? onDetailsTap;

  const DeviceStatusCard({
    super.key,
    required this.device,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.router_outlined, color: Colors.white54, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No LoRa Beacon Linked',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Operating via Smartphone GPS',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isOnline = (device!.status ?? '').toUpperCase() == 'ONLINE';
    final battery = device!.battery;
    final rssi = device!.rssi;

    Color batteryColor = Colors.greenAccent;
    if (battery != null && battery < 20) {
      batteryColor = Colors.redAccent;
    } else if (battery != null && battery < 50) {
      batteryColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline
              ? AppConstants.primaryColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sensors, color: AppConstants.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device!.deviceName ?? device!.deviceId,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ID: ${device!.deviceId}',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.greenAccent.withValues(alpha: 0.15)
                      : Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.greenAccent : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric(
                icon: Icons.battery_charging_full_rounded,
                iconColor: batteryColor,
                label: 'BATTERY',
                value: battery != null ? '${battery.toStringAsFixed(0)}%' : 'N/A',
              ),
              _buildMiniMetric(
                icon: Icons.network_cell_rounded,
                iconColor: Colors.cyanAccent,
                label: 'SIGNAL',
                value: rssi != null ? '${rssi.toStringAsFixed(0)} dBm' : 'N/A',
              ),
              _buildMiniMetric(
                icon: Icons.gps_fixed_rounded,
                iconColor: Colors.amberAccent,
                label: 'GPS LOCK',
                value: device!.gpsStatus ?? 'N/A',
              ),
            ],
          ),
          if (onDetailsTap != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onDetailsTap,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('View Hardware Specs', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
