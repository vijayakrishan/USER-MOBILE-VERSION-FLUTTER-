import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyEmail = 'user_email';
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'user_role';
  static const String _keyName = 'user_name';
  static const String _keyPhone = 'user_phone';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Save cryptographic JWT token into hardware-backed Secure Storage
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Retrieve JWT token from Secure Storage
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Delete JWT token from Secure Storage
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  /// Save actual database user UUID into Secure Storage
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _keyUserId, value: userId);
  }

  /// Retrieve database user UUID from Secure Storage
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _keyUserId);
  }

  /// Delete database user UUID from Secure Storage
  Future<void> deleteUserId() async {
    await _secureStorage.delete(key: _keyUserId);
  }

  /// Retrieve authenticated user role from Secure Storage
  Future<String?> getRole() async {
    return await _secureStorage.read(key: _keyRole);
  }

  /// Clear authentication session from Secure Storage
  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyUserId);
    await _secureStorage.delete(key: _keyRole);
  }

  /// Save complete authentication session:
  /// Sensitive credentials (JWT, UUID, Role) go into FlutterSecureStorage.
  /// Non-sensitive profile cache (email, name, phone) go into SharedPreferences.
  Future<void> saveAuthData({
    required String token,
    required String role,
    required String userId,
    String? email,
    String? name,
    String? phone,
  }) async {
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyUserId, value: userId);
    await _secureStorage.write(key: _keyRole, value: role);

    final prefs = await SharedPreferences.getInstance();
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_keyEmail, email);
    }
    if (name != null && name.isNotEmpty) {
      await prefs.setString(_keyName, name);
    }
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString(_keyPhone, phone);
    }
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  Future<void> setUserId(String id) async {
    await saveUserId(id);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
