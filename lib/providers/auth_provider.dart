import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? _phone;
  String? get phone => _phone;

  String? _userId;
  String? get userId => _userId;

  String? _role;
  String? get role => _role;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _token != null &&
      _token!.isNotEmpty &&
      _userId != null &&
      _userId!.isNotEmpty;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _token = await _storageService.getToken();
    _email = await _storageService.getEmail();
    _userId = await _storageService.getUserId();
    _name = await _storageService.getName();
    _phone = await _storageService.getPhone();
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _authService.login(LoginRequest(
        identifier: identifier.trim(),
        password: password,
      ));

      if (res.token.isEmpty) {
        throw Exception('Authentication failed: Missing JWT token from server');
      }

      // Ensure the actual database UUID is provided
      final receivedUserId = res.userId;
      if (receivedUserId == null || receivedUserId.trim().isEmpty) {
        throw Exception('Authentication failed: Missing user ID from server');
      }

      _token = res.token;
      _userId = receivedUserId.trim();
      _role = res.role;
      _name = res.name;
      _email = res.email ?? (identifier.contains('@') ? identifier.trim() : null);
      _phone = res.phone ?? (!identifier.contains('@') ? identifier.trim() : null);

      await _storageService.saveAuthData(
        token: res.token,
        role: res.role,
        userId: _userId!,
        email: _email,
        name: _name,
        phone: _phone,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Login error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(RegisterRequest req) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final responseText = await _authService.register(req);
      _name = req.name;
      _phone = req.phone;
      _email = req.email;
      return responseText;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Registration error: $_errorMessage');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPhone(String phone, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.verifyPhone(phone.trim(), otp.trim());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Verify phone error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmail(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.verifyEmail(email.trim(), otp.trim());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Verify email error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestPasswordReset(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.requestPasswordReset(identifier.trim());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Request reset OTP error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPasswordResetOtp(String identifier, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.verifyPasswordResetOtp(identifier.trim(), otp.trim());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Verify reset OTP error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String identifier, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.resetPassword(identifier.trim(), newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Reset password error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _token = null;
    _email = null;
    _name = null;
    _phone = null;
    _userId = null;
    _role = null;
    _errorMessage = null;
    notifyListeners();
  }
}
