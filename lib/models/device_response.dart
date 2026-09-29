class DeviceResponse {
  final String deviceId;
  final String? deviceName;
  final String? status;
  final int? battery;
  final int? rssi;
  final double? snr;
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
      battery: (json['battery'] as num?)?.toInt(),
      rssi: (json['rssi'] as num?)?.toInt(),
      snr: (json['snr'] as num?)?.toDouble(),
      gpsStatus: json['gpsStatus'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      gpsPrecision: (json['gpsPrecision'] as num?)?.toDouble(),
      packetsSent: (json['packetsSent'] as num?)?.toInt(),
      loraModule: json['loraModule'],
      loraFrequency: json['loraFrequency'],
      lastSeen: json['lastSeen'],
    );
  }
}
