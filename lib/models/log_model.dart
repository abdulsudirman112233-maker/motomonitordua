class LogModel {
  final String eventType;
  final String message;
  final String datetime;
  final double? latitude;
  final double? longitude;
  final double? speed;

  LogModel({
    required this.eventType,
    required this.message,
    required this.datetime,
    this.latitude,
    this.longitude,
    this.speed,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      eventType: json['event_type']?.toString() ?? 'INFO',
      message: json['message']?.toString() ?? '-',
      datetime: json['datetime']?.toString() ?? DateTime.now().toIso8601String(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'message': message,
      'datetime': datetime,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
    };
  }
}
