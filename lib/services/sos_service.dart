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
      throw Exception('Failed to create SOS alert: ${response.body}');
    }
  }

  Future<List<SosAlert>> getUserSosHistory(String userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.sosService}/user/$userId'),
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
      Uri.parse('${ApiConfig.sosService}/$id'),
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
      Uri.parse('${ApiConfig.sosService}/$id/status?status=CANCELLED'),
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
