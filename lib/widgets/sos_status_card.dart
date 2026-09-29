import 'package:flutter/material.dart';
import '../models/sos_alert.dart';
import '../utils/constants.dart';

class SosStatusCard extends StatelessWidget {
  final SosAlert alert;
  final VoidCallback onCancel;
  final bool isCancelling;

  const SosStatusCard({
    super.key,
    required this.alert,
    required this.onCancel,
    this.isCancelling = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orangeAccent;
      case 'ACCEPTED':
        return Colors.blueAccent;
      case 'IN_PROGRESS':
        return Colors.cyanAccent;
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'CANCELLED':
        return Colors.redAccent;
      default:
        return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (alert.status ?? 'PENDING').toUpperCase();
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
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
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DISTRESS BEACON ACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.emergencyDetails.isNotEmpty
                ? alert.emergencyDetails
                : 'Emergency assistance requested',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const Spacer(),
              if (alert.priority.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PRIORITY: ${alert.priority}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (alert.assignedTeamId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.group, size: 16, color: Colors.cyanAccent),
                const SizedBox(width: 6),
                Text(
                  'Assigned Squad: ${alert.assignedTeamId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isCancelling ? null : onCancel,
              icon: isCancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                    )
                  : const Icon(Icons.cancel_outlined, size: 18),
              label: Text(isCancelling ? 'CANCELLING...' : 'CANCEL DISTRESS SIGNAL'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
