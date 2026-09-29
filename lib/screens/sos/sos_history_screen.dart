import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/sos_alert.dart';
import '../../utils/constants.dart';

class SosHistoryScreen extends StatefulWidget {
  const SosHistoryScreen({super.key});

  @override
  State<SosHistoryScreen> createState() => _SosHistoryScreenState();
}

class _SosHistoryScreenState extends State<SosHistoryScreen> {
  String _selectedStatusFilter = 'ALL';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;
    app.fetchSosHistory(auth.userId!, auth.token!);
  }

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
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Apply filtering
    final filteredList = app.sosHistory.where((alert) {
      final status = (alert.status ?? 'PENDING').toUpperCase();
      if (_selectedStatusFilter != 'ALL' && status != _selectedStatusFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final details = alert.emergencyDetails.toLowerCase();
        final id = (alert.id ?? '').toLowerCase();
        return details.contains(q) || id.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Rescue Timeline'),
        backgroundColor: AppConstants.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search distress messages or IDs...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Status Filter Chips
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'ALL',
                  'PENDING',
                  'IN_PROGRESS',
                  'COMPLETED',
                  'CANCELLED',
                ].map((status) {
                  final isSelected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedStatusFilter = status);
                      },
                      selectedColor: AppConstants.primaryColor,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      backgroundColor: AppConstants.surfaceColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Results List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadHistory(),
                color: AppConstants.primaryColor,
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_outlined, size: 54, color: Colors.white24),
                            const SizedBox(height: 12),
                            const Text(
                              'No distress logs found',
                              style: TextStyle(fontSize: 15, color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final alert = filteredList[index];
                          return _buildSosCard(alert, auth, app);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosCard(SosAlert alert, AuthProvider auth, AppProvider app) {
    final status = (alert.status ?? 'PENDING').toUpperCase();
    final statusColor = _getStatusColor(status);
    final bool canCancel = status == 'PENDING' || status == 'IN_PROGRESS' || status == 'ACCEPTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SOS-${alert.id?.substring(0, 8).toUpperCase() ?? 'REQ'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.emergencyDetails.isNotEmpty
                ? alert.emergencyDetails
                : 'Emergency distress broadcasted',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const Spacer(),
              if (alert.createdAt != null) ...[
                const Icon(Icons.access_time, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  alert.createdAt!.split('T').first,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ],
          ),
          if (alert.assignedTeamId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.group, size: 14, color: Colors.cyanAccent),
                const SizedBox(width: 6),
                Text(
                  'Squad: ${alert.assignedTeamId}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
              ],
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  if (!auth.isAuthenticated) return;
                  await app.cancelSos(alert.id!, auth.token!, auth.userId!);
                },
                icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                label: const Text('Cancel Request', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
