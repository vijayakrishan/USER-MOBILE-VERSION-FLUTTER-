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
      Uri.parse('${ApiConfig.authService}/login'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<String> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authService}/register'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body; // Might be plain string or JSON
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<String> verifyEmail(String email, String otp) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authService}/verify-email'),
      headers: _headers,
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Email verification failed: ${response.body}');
    }
  }

  Future<String> verifyPhone(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authService}/verify-phone'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Phone verification failed: ${response.body}');
    }
  }

  Future<String> requestPasswordReset(String identifier) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authService}/forgot-password/request-otp'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to request OTP: ${response.body}');
    }
  }

  Future<String> verifyPasswordResetOtp(String identifier, String otp) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authService}/forgot-password/verify-otp'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  }

  Future<String> resetPassword(String identifier, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authService}/forgot-password/reset'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier, 'newPassword': newPassword}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }
}
