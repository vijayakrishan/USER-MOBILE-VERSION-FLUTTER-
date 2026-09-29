import os

base_dir = r"c:\Users\Vijayakrishnan.R\OneDrive\Desktop\my-app1\resqmesh-user-mobile\flutter-app\lib"

files = {
    "utils/constants.dart": """
import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF00ADB5);
  static const Color backgroundColor = Color(0xFF222831);
  static const Color surfaceColor = Color(0xFF393E46);
  static const Color errorColor = Color(0xFFFF2E63);
  static const Color textColor = Color(0xFFEEEEEE);
}
""",
    "utils/phone_utils.dart": """
class PhoneUtils {
  static String formatIndianPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      return '+91$cleanPhone';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return '+$cleanPhone';
    }
    return phone;
  }
}
""",
    "config/api_config.dart": """
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2'; // Emulator localhost
  
  static const String authService = '$baseUrl:8081/api/auth';
  static const String userService = '$baseUrl:8083/api/users';
  static const String sosService = '$baseUrl:8085/api/sos';
  static const String deviceService = '$baseUrl:8082/api/devices';
}
""",
    "models/user.dart": """
class User {
  final String id;
  final String identifier;
  final String role;
  final String token;
  final String? workerId;
  final String? teamId;
  final String? teamName;

  User({
    required this.id,
    required this.identifier,
    required this.role,
    required this.token,
    this.workerId,
    this.teamId,
    this.teamName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      identifier: json['identifier'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      workerId: json['workerId'],
      teamId: json['teamId'],
      teamName: json['teamName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifier': identifier,
      'role': role,
      'token': token,
      'workerId': workerId,
      'teamId': teamId,
      'teamName': teamName,
    };
  }
}
""",
    "models/login_request.dart": """
class LoginRequest {
  final String identifier;
  final String password;

  LoginRequest({required this.identifier, required this.password});

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'password': password,
  };
}
""",
    "models/login_response.dart": """
class LoginResponse {
  final String message;
  final String role;
  final String token;
  final String? workerId;
  final String? teamId;
  final String? teamName;

  LoginResponse({
    required this.message,
    required this.role,
    required this.token,
    this.workerId,
    this.teamId,
    this.teamName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      workerId: json['workerId'],
      teamId: json['teamId'],
      teamName: json['teamName'],
    );
  }
}
""",
    "models/register_request.dart": """
class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
  };
}
""",
    "models/sos_alert.dart": """
class SosAlert {
  final String? id;
  final String senderUserId;
  final String senderEmail;
  final String? deviceId;
  final String? victimName;
  final String? victimContact;
  final double latitude;
  final double longitude;
  final String priority;
  final String emergencyDetails;
  final String? status;
  final String? assignedTeamId;
  final String? acceptedWorkerId;
  final String? createdAt;
  final String? acceptedAt;
  final String? completedAt;
  final int? version;

  SosAlert({
    this.id,
    required this.senderUserId,
    required this.senderEmail,
    this.deviceId,
    this.victimName,
    this.victimContact,
    required this.latitude,
    required this.longitude,
    required this.priority,
    required this.emergencyDetails,
    this.status,
    this.assignedTeamId,
    this.acceptedWorkerId,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.version,
  });

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    return SosAlert(
      id: json['id'],
      senderUserId: json['senderUserId'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      deviceId: json['deviceId'],
      victimName: json['victimName'],
      victimContact: json['victimContact'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : 0.0,
      priority: json['priority'] ?? 'HIGH',
      emergencyDetails: json['emergencyDetails'] ?? '',
      status: json['status'],
      assignedTeamId: json['assignedTeamId'],
      acceptedWorkerId: json['acceptedWorkerId'],
      createdAt: json['createdAt'],
      acceptedAt: json['acceptedAt'],
      completedAt: json['completedAt'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'senderUserId': senderUserId,
      'senderEmail': senderEmail,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
      'emergencyDetails': emergencyDetails,
    };
    if (deviceId != null) data['deviceId'] = deviceId;
    if (victimName != null) data['victimName'] = victimName;
    if (victimContact != null) data['victimContact'] = victimContact;
    if (id != null) data['id'] = id;
    if (status != null) data['status'] = status;
    return data;
  }
}
""",
    "models/device_response.dart": """
class DeviceResponse {
  final String deviceId;
  final String? deviceName;
  final String? status;
  final int? battery;
  final int? rssi;
  final int? snr;
  final String? gpsStatus;
  final double? latitude;
  final double? longitude;
  final double? gpsPrecision;
  final int? packetsSent;
  final String? loraModule;
  final String? loraFrequency;
  final String? lastSeen;

  DeviceResponse({
    required this.deviceId,
    this.deviceName,
    this.status,
    this.battery,
    this.rssi,
    this.snr,
    this.gpsStatus,
    this.latitude,
    this.longitude,
    this.gpsPrecision,
    this.packetsSent,
    this.loraModule,
    this.loraFrequency,
    this.lastSeen,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'],
      status: json['status'],
      battery: json['battery'],
      rssi: json['rssi'],
      snr: json['snr'],
      gpsStatus: json['gpsStatus'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      gpsPrecision: json['gpsPrecision'] != null ? (json['gpsPrecision'] as num).toDouble() : null,
      packetsSent: json['packetsSent'],
      loraModule: json['loraModule'],
      loraFrequency: json['loraFrequency'],
      lastSeen: json['lastSeen'],
    );
  }
}
""",
    "models/user_profile.dart": """
class UserProfile {
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? relationship;
  final String? medicalInformation;
  final String? designation;

  UserProfile({
    this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.relationship,
    this.medicalInformation,
    this.designation,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      address: json['address'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactNumber: json['emergency_contact_number'],
      relationship: json['relationship'],
      medicalInformation: json['medical_information'],
      designation: json['designation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
      'relationship': relationship,
      'medical_information': medicalInformation,
      'designation': designation,
    };
  }
}
""",
    "services/storage_service.dart": """
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyEmail = 'user_email';
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'user_role';

  Future<void> saveAuthData(String email, String token, String role, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRole, role);
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }
  
  Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
""",
    "services/auth_service.dart": """
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

class AuthService {
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/login'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: \${response.body}');
    }
  }

  Future<String> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/register'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body; // Might be plain string or JSON
    } else {
      throw Exception('Failed to register: \${response.body}');
    }
  }

  Future<String> verifyEmail(String email, String otp) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/verify-email'),
      headers: _headers,
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Email verification failed: \${response.body}');
    }
  }

  Future<String> verifyPhone(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/verify-phone'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Phone verification failed: \${response.body}');
    }
  }

  Future<String> requestPasswordReset(String identifier) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/forgot-password/request-otp'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to request OTP: \${response.body}');
    }
  }

  Future<String> verifyPasswordResetOtp(String identifier, String otp) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/forgot-password/verify-otp'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to verify OTP: \${response.body}');
    }
  }

  Future<String> resetPassword(String identifier, String newPassword) async {
    final response = await http.post(
      Uri.parse('\${ApiConfig.authService}/forgot-password/reset'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier, 'newPassword': newPassword}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to reset password: \${response.body}');
    }
  }
}
""",
    "services/user_service.dart": """
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_profile.dart';

class UserService {
  Future<UserProfile> getProfile(String email, String token) async {
    final response = await http.get(
      Uri.parse('\${ApiConfig.userService}/profile/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get profile');
    }
  }

  Future<UserProfile> updateProfile(String email, UserProfile profile, String token) async {
    final response = await http.put(
      Uri.parse('\${ApiConfig.userService}/profile/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toJson()),
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
""",
    "services/sos_service.dart": """
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/sos_alert.dart';

class SosService {
  Future<SosAlert> createSosAlert(SosAlert alert, String token) async {
    final response = await http.post(
      Uri.parse(ApiConfig.sosService),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(alert.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SosAlert.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create SOS alert: \${response.body}');
    }
  }

  Future<List<SosAlert>> getUserSosHistory(String userId, String token) async {
    final response = await http.get(
      Uri.parse('\${ApiConfig.sosService}/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SosAlert.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch SOS history');
    }
  }

  Future<SosAlert> getSosAlert(String id, String token) async {
    final response = await http.get(
      Uri.parse('\${ApiConfig.sosService}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return SosAlert.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get SOS alert');
    }
  }

  Future<SosAlert> cancelSosAlert(String id, String token) async {
    final response = await http.put(
      Uri.parse('\${ApiConfig.sosService}/$id/status?status=CANCELLED'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return SosAlert.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to cancel SOS alert');
    }
  }
}
""",
    "services/device_service.dart": """
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/device_response.dart';

class DeviceService {
  Future<DeviceResponse> getDeviceDetails(String deviceId, String token) async {
    final response = await http.get(
      Uri.parse('\${ApiConfig.deviceService}/$deviceId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return DeviceResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch device details');
    }
  }
}
""",
    "providers/auth_provider.dart": """
import 'package:flutter/material.dart';
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
  
  String? _userId;
  String? get userId => _userId;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _token = await _storageService.getToken();
    _email = await _storageService.getEmail();
    _userId = await _storageService.getUserId();
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _authService.login(LoginRequest(identifier: identifier, password: password));
      _token = res.token;
      _email = identifier; // Using identifier as email for now
      
      // If we don't have a userId yet, we might want to generate a mock one or try to fetch it
      // from profile, but let's just use email as ID if we don't have one
      if (_userId == null) {
          _userId = identifier; // Fallback
      }
      
      await _storageService.saveAuthData(identifier, res.token, res.role, userId: _userId);
      return true;
    } catch (e) {
      print(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(RegisterRequest req) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.register(req);
      // Temporarily store userId as email during registration since it's unique
      _userId = req.email;
      await _storageService.setUserId(_userId!);
      return true;
    } catch (e) {
      print(e);
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
    _userId = null;
    notifyListeners();
  }
}
""",
    "providers/app_provider.dart": """
import 'package:flutter/material.dart';
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

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  DeviceResponse? _currentDevice;
  DeviceResponse? get currentDevice => _currentDevice;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  Future<void> updateLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    _currentPosition = await Geolocator.getCurrentPosition();
    notifyListeners();
  }

  Future<void> fetchUserProfile(String email, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _userService.getProfile(email, token);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> triggerSos(String userId, String email, String token, {String? details}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await updateLocation();
      final alert = SosAlert(
        senderUserId: userId,
        senderEmail: email,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        priority: 'HIGH',
        emergencyDetails: details ?? 'Emergency SOS triggered',
      );
      await _sosService.createSosAlert(alert, token);
      await fetchSosHistory(userId, token);
      return true;
    } catch (e) {
      print(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSosHistory(String userId, String token) async {
    try {
      _sosHistory = await _sosService.getUserSosHistory(userId, token);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
  
  Future<void> cancelSos(String id, String token, String userId) async {
      try {
          await _sosService.cancelSosAlert(id, token);
          await fetchSosHistory(userId, token);
      } catch (e) {
          print(e);
      }
  }

  Future<void> fetchDevice(String deviceId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentDevice = await _deviceService.getDeviceDetails(deviceId, token);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
""",
    "screens/auth/login_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 100, color: Theme.of(context).primaryColor),
              SizedBox(height: 32),
              Text('ResQMesh', style: Theme.of(context).textTheme.headlineLarge),
              SizedBox(height: 32),
              TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email/Phone', border: OutlineInputBorder())),
              SizedBox(height: 16),
              TextField(controller: _passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              SizedBox(height: 32),
              auth.isLoading 
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (await auth.login(_emailCtrl.text, _passCtrl.text)) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
                      }
                    },
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    child: Text('LOGIN'),
                  ),
              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
              }, child: Text('Create an Account')),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    "screens/auth/register_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/register_request.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 16),
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 16),
            TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: 'Phone')),
            SizedBox(height: 16),
            TextField(controller: _passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 32),
            auth.isLoading 
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    final req = RegisterRequest(
                      name: _nameCtrl.text, email: _emailCtrl.text, phone: _phoneCtrl.text, password: _passCtrl.text
                    );
                    if (await auth.register(req)) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful. Please login.')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
                    }
                  },
                  child: Text('REGISTER'),
                )
          ],
        ),
      ),
    );
  }
}
""",
    "screens/home/home_screen.dart": """
import 'package:flutter/material.dart';
import '../dashboard/user_dashboard_screen.dart';
import '../device/device_details_screen.dart';
import '../sos/sos_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    UserDashboardScreen(),
    DeviceDetailsScreen(),
    SosHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.developer_board), label: 'Device'),
          NavigationDestination(icon: Icon(Icons.history), label: 'SOS'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
""",
    "widgets/sos_button.dart": """
import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SosButton({required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              spreadRadius: 10,
              blurRadius: 20,
            )
          ]
        ),
        child: Center(
          child: isLoading 
            ? CircularProgressIndicator(color: Colors.white)
            : Text('SOS', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
""",
    "screens/dashboard/user_dashboard_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/sos_button.dart';

class UserDashboardScreen extends StatefulWidget {
  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).updateLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Emergency Response', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 48),
            SosButton(
              isLoading: app.isLoading,
              onPressed: () async {
                bool success = await app.triggerSos(auth.userId ?? auth.email ?? '', auth.email ?? '', auth.token ?? '');
                if (success) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS Triggered Successfully!')));
                }
              },
            ),
            SizedBox(height: 32),
            if (app.currentPosition != null)
              Text('Location: \${app.currentPosition!.latitude.toStringAsFixed(4)}, \${app.currentPosition!.longitude.toStringAsFixed(4)}')
            else
              Text('Acquiring location...'),
          ],
        ),
      ),
    );
  }
}
""",
    "screens/device/device_details_screen.dart": """
import 'package:flutter/material.dart';

class DeviceDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LoRa Device')),
      body: Center(child: Text('Device not connected.')),
    );
  }
}
""",
    "screens/sos/sos_history_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';

class SosHistoryScreen extends StatefulWidget {
  @override
  _SosHistoryScreenState createState() => _SosHistoryScreenState();
}

class _SosHistoryScreenState extends State<SosHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userId != null && auth.token != null) {
        Provider.of<AppProvider>(context, listen: false).fetchSosHistory(auth.userId!, auth.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(title: Text('SOS History')),
      body: ListView.builder(
        itemCount: app.sosHistory.length,
        itemBuilder: (context, index) {
          final alert = app.sosHistory[index];
          return ListTile(
            title: Text(alert.emergencyDetails),
            subtitle: Text('Status: \${alert.status ?? 'PENDING'}'),
            trailing: alert.status != 'CANCELLED' && alert.status != 'COMPLETED'
              ? IconButton(icon: Icon(Icons.cancel, color: Colors.red), onPressed: () {
                  app.cancelSos(alert.id!, auth.token!, auth.userId!);
              }) : null,
          );
        },
      ),
    );
  }
}
""",
    "screens/profile/profile_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.email != null && auth.token != null) {
        Provider.of<AppProvider>(context, listen: false).fetchUserProfile(auth.email!, auth.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () {
            auth.logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          })
        ],
      ),
      body: app.isLoading 
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: \${auth.email}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                if (app.userProfile != null) ...[
                  Text('Name: \${app.userProfile!.name ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                  Text('Phone: \${app.userProfile!.phone ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                ]
              ],
            ),
          ),
    );
  }
}
""",
    "screens/auth/verify_email_screen.dart": """
import 'package:flutter/material.dart';
class VerifyEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Verify Email')), body: Center(child: Text('TBD')));
  }
}
""",
    "screens/auth/verify_phone_screen.dart": """
import 'package:flutter/material.dart';
class VerifyPhoneScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Verify Phone')), body: Center(child: Text('TBD')));
  }
}
""",
    "screens/auth/forgot_password_screen.dart": """
import 'package:flutter/material.dart';
class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Forgot Password')), body: Center(child: Text('TBD')));
  }
}
""",
    "widgets/device_status_card.dart": """
import 'package:flutter/material.dart';
class DeviceStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Device Status: OK')));
  }
}
""",
    "widgets/sos_status_card.dart": """
import 'package:flutter/material.dart';
class SosStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Active SOS: None')));
  }
}
""",
    "widgets/stat_card.dart": """
import 'package:flutter/material.dart';
class StatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Stat: 0')));
  }
}
""",
    "main.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'ResQMesh User',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: AppConstants.primaryColor,
            surface: AppConstants.surfaceColor,
            background: AppConstants.backgroundColor,
            error: AppConstants.errorColor,
          ),
          scaffoldBackgroundColor: AppConstants.backgroundColor,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.token != null) {
              return HomeScreen();
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}
"""
}

for filepath, content in files.items():
    full_path = os.path.join(base_dir, filepath)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(content.strip())
        
print("All files created successfully!")
