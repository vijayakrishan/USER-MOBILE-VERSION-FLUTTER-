import 'package:flutter_test/flutter_test.dart';
import 'package:resqmesh_user/config/api_config.dart';
import 'package:resqmesh_user/models/login_response.dart';
import 'package:resqmesh_user/models/user_profile.dart';
import 'package:resqmesh_user/models/device_response.dart';
import 'package:resqmesh_user/models/sos_alert.dart';

void main() {
  group('ApiConfig Tests', () {
    test('Default host is 10.0.2.2 for Android emulator', () {
      expect(ApiConfig.host, equals('10.0.2.2'));
      expect(ApiConfig.baseUrl, equals('http://10.0.2.2'));
    });

    test('Microservice endpoints use correct default ports', () {
      expect(ApiConfig.authService, equals('http://10.0.2.2:8081/api/auth'));
      expect(ApiConfig.userService, equals('http://10.0.2.2:8083/api/users'));
      expect(ApiConfig.sosService, equals('http://10.0.2.2:8085/api/sos'));
      expect(ApiConfig.deviceService, equals('http://10.0.2.2:8082/api/devices'));
    });
  });

  group('Model Serialization Tests', () {
    test('LoginResponse correctly parses database UUID and JWT token', () {
      final json = {
        'message': 'Login successful',
        'role': 'USER',
        'token': 'eyJhbGciOiJIUzI1NiJ9.sample.jwt.token',
        'userId': 'usr-uuid-12345-abcdef',
        'name': 'Test User',
        'email': 'user@example.com',
        'phone': '9876543210',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.message, equals('Login successful'));
      expect(response.role, equals('USER'));
      expect(response.token, equals('eyJhbGciOiJIUzI1NiJ9.sample.jwt.token'));
      expect(response.userId, equals('usr-uuid-12345-abcdef'));
      expect(response.name, equals('Test User'));
      expect(response.email, equals('user@example.com'));
      expect(response.phone, equals('9876543210'));
    });

    test('UserProfile parses full details correctly', () {
      final json = {
        'id': 'usr-uuid-12345-abcdef',
        'name': 'Test User',
        'phone': '9876543210',
        'email': 'user@example.com',
        'emergency_contact_name': 'Emergency Contact',
        'emergency_contact_number': '9123456789',
        'medical_information': 'None',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, equals('usr-uuid-12345-abcdef'));
      expect(profile.name, equals('Test User'));
      expect(profile.phone, equals('9876543210'));
      expect(profile.emergencyContactName, equals('Emergency Contact'));
      expect(profile.medicalInformation, equals('None'));
    });

    test('DeviceResponse parses telemetry correctly', () {
      final json = {
        'deviceId': 'DEV-001',
        'deviceName': 'LoRa Node 1',
        'status': 'ONLINE',
        'battery': 95,
        'rssi': -65,
        'snr': 9.5,
        'gpsStatus': 'LOCKED',
        'latitude': 12.9716,
        'longitude': 77.5946,
      };

      final device = DeviceResponse.fromJson(json);

      expect(device.deviceId, equals('DEV-001'));
      expect(device.deviceName, equals('LoRa Node 1'));
      expect(device.status, equals('ONLINE'));
      expect(device.battery, equals(95));
      expect(device.latitude, equals(12.9716));
    });

    test('SosAlert parses correctly', () {
      final json = {
        'id': 'sos-001',
        'senderUserId': 'usr-uuid-12345-abcdef',
        'senderEmail': 'user@example.com',
        'victimName': 'Victim',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'priority': 'HIGH',
        'status': 'PENDING',
        'emergencyDetails': 'Need medical assistance',
      };

      final alert = SosAlert.fromJson(json);

      expect(alert.id, equals('sos-001'));
      expect(alert.senderUserId, equals('usr-uuid-12345-abcdef'));
      expect(alert.status, equals('PENDING'));
      expect(alert.priority, equals('HIGH'));
    });
  });
}
