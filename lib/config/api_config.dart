class ApiConfig {
  /// Host used by the physical Android device through ADB reverse.
  /// ADB reverse maps the phone's localhost to the PC's localhost.
  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '127.0.0.1',
  );

  static String get baseUrl => 'http://$host';

  // Auth Service - 8081
  static String get authService => '$baseUrl:8081/api/auth';

  // User Service - 8083
  static String get userService => '$baseUrl:8083/api/users';

  // Rescue Service - 8085
  static String get sosService => '$baseUrl:8085/api/sos';

  // Device Service - 8082
  static String get deviceService => '$baseUrl:8082/api/devices';
}