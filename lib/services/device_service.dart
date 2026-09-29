import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/device_response.dart';

class DeviceService {
  Future<DeviceResponse> getDeviceDetails(String deviceId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.deviceService}/$deviceId'),
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
