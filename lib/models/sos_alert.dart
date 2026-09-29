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
