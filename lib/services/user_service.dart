import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_profile.dart';

class UserService {
  Future<UserProfile> getProfile(String email, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.userService}/profile/$email'),
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
      Uri.parse('${ApiConfig.userService}/profile/$email'),
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
