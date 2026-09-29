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
