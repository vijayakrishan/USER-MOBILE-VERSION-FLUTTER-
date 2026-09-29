class LoginResponse {
  final String message;
  final String role;
  final String token;
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? workerId;
  final String? teamId;
  final String? teamName;

  LoginResponse({
    required this.message,
    required this.role,
    required this.token,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.workerId,
    this.teamId,
    this.teamName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      workerId: json['workerId'],
      teamId: json['teamId'],
      teamName: json['teamName'],
    );
  }
}
