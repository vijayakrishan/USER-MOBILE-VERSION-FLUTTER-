import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/sos_service.dart';
import '../services/user_service.dart';
import '../services/device_service.dart';
import '../models/sos_alert.dart';
import '../models/user_profile.dart';
import '../models/device_response.dart';

class AppProvider extends ChangeNotifier {
  final SosService _sosService = SosService();
  final UserService _userService = UserService();
  final DeviceService _deviceService = DeviceService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SosAlert> _sosHistory = [];
  List<SosAlert> get sosHistory => _sosHistory;

  SosAlert? _activeSos;
  SosAlert? get activeSos => _activeSos;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  DeviceResponse? _currentDevice;
  DeviceResponse? get currentDevice => _currentDevice;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _pollingTimer;
  String? _pollingUserId;
  String? _pollingToken;
  String? _pollingDeviceId;

  static const List<String> activeStatuses = [
    'PENDING',
    'ACCEPTED',
    'IN_PROGRESS',
    'ACTIVE'
  ];

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  void startPolling({
    required String userId,
    required String token,
    String? deviceId,
  }) {
    if (userId.isEmpty || token.isEmpty) {
      debugPrint('startPolling aborted: Missing authenticated identity or token');
      return;
    }

    _pollingUserId = userId;
    _pollingToken = token;
    _pollingDeviceId = deviceId ?? 'DEV-01';

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pollingUserId != null && _pollingToken != null) {
        fetchSosHistory(_pollingUserId!, _pollingToken!);
        if (_pollingDeviceId != null) {
          fetchDevice(_pollingDeviceId!, _pollingToken!);
        }
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingUserId = null;
    _pollingToken = null;
    _pollingDeviceId = null;
  }

  Future<void> updateLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> fetchUserProfile(String identifier, String token) async {
    if (identifier.isEmpty || token.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userProfile = await _userService.getProfile(identifier, token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Fetch profile error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile(
      String identifier, UserProfile profile, String token) async {
    if (identifier.isEmpty || token.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userProfile = await _userService.updateProfile(identifier, profile, token);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Update profile error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> triggerSos({
    required String userId,
    required String token,
    required String victimName,
    String? email,
    String? victimContact,
    String? details,
    String? priority,
    String? deviceId,
  }) async {
    if (userId.isEmpty || token.isEmpty) {
      _errorMessage = 'User is not authenticated. Please log in.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await updateLocation();

      final alert = SosAlert(
        senderUserId: userId,
        senderEmail: email ?? '',
        deviceId: deviceId ?? 'DEV-01',
        victimName: victimName.trim().isEmpty ? 'Survivor' : victimName.trim(),
        victimContact: victimContact ?? '',
        latitude: _currentPosition?.latitude ?? 11.0168,
        longitude: _currentPosition?.longitude ?? 76.9558,
        priority: priority ?? 'HIGH',
        emergencyDetails: details ?? 'Emergency assistance requested via Mobile App',
      );

      final created = await _sosService.createSosAlert(alert, token);
      _activeSos = created;
      await fetchSosHistory(userId, token);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Trigger SOS error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSosHistory(String userId, String token) async {
    if (userId.isEmpty || token.isEmpty) return;

    try {
      final list = await _sosService.getUserSosHistory(userId, token);
      _sosHistory = list;

      // Identify active SOS
      _activeSos = null;
      for (final sos in _sosHistory) {
        final status = (sos.status ?? '').trim().toUpperCase();
        if (activeStatuses.contains(status)) {
          _activeSos = sos;
          break;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch SOS history error: $e');
    }
  }

  Future<bool> cancelSos(String id, String token, String userId) async {
    if (id.isEmpty || token.isEmpty) return false;

    _isLoading = true;
    notifyListeners();
    try {
      await _sosService.cancelSosAlert(id, token);
      if (_activeSos?.id == id) {
        _activeSos = null;
      }
      await fetchSosHistory(userId, token);
      return true;
    } catch (e) {
      debugPrint('Cancel SOS error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDevice(String deviceId, String token) async {
    if (deviceId.isEmpty || token.isEmpty) return;

    try {
      _currentDevice = await _deviceService.getDeviceDetails(deviceId, token);
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch device error: $e');
    }
  }
}
