class TelemetryModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double heading;
  final int satellites;
  final double hdop;
  final bool gpsFixed;
  final int gsmCsq;
  final int gsmSignalPercent;
  final String gsmNetwork;
  final double batteryVoltage;
  final String powerSource;
  final bool vibrationDetected;
  final bool engineRunning;
  final String connectionMode;
  final int timestamp;

  TelemetryModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.satellites,
    required this.hdop,
    required this.gpsFixed,
    required this.gsmCsq,
    required this.gsmSignalPercent,
    required this.gsmNetwork,
    required this.batteryVoltage,
    required this.powerSource,
    required this.vibrationDetected,
    required this.engineRunning,
    required this.connectionMode,
    required this.timestamp,
  });

  factory TelemetryModel.defaultState() {
    return TelemetryModel(
      latitude: -5.460095,
      longitude: 122.616677,
      altitude: 40.0,
      speed: 0.0,
      heading: 0.0,
      satellites: 8,
      hdop: 1.1,
      gpsFixed: true,
      gsmCsq: 22,
      gsmSignalPercent: 75,
      gsmNetwork: "INDOSAT",
      batteryVoltage: 12.6,
      powerSource: "ACCU_12V",
      vibrationDetected: false,
      engineRunning: false,
      connectionMode: "WIFI_ONLINE",
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? -5.460095,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 122.616677,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      satellites: (json['satellites'] as num?)?.toInt() ?? 0,
      hdop: (json['hdop'] as num?)?.toDouble() ?? 1.0,
      gpsFixed: json['gps_fixed'] ?? true,
      gsmCsq: (json['gsm_csq'] as num?)?.toInt() ?? 0,
      gsmSignalPercent: (json['gsm_signal_percent'] as num?)?.toInt() ?? 0,
      gsmNetwork: json['gsm_network']?.toString() ?? "CELLULAR",
      batteryVoltage: (json['battery_voltage'] as num?)?.toDouble() ?? 12.6,
      powerSource: json['power_source']?.toString() ?? "ACCU_12V",
      vibrationDetected: json['vibration_detected'] ?? false,
      engineRunning: json['engine_running'] ?? false,
      connectionMode: json['connection_mode']?.toString() ?? "WIFI_ONLINE",
      timestamp: (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'satellites': satellites,
      'hdop': hdop,
      'gps_fixed': gpsFixed,
      'gsm_csq': gsmCsq,
      'gsm_signal_percent': gsmSignalPercent,
      'gsm_network': gsmNetwork,
      'battery_voltage': batteryVoltage,
      'power_source': powerSource,
      'vibration_detected': vibrationDetected,
      'engine_running': engineRunning,
      'connection_mode': connectionMode,
      'timestamp': timestamp,
    };
  }

  TelemetryModel copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    int? satellites,
    double? hdop,
    bool? gpsFixed,
    int? gsmCsq,
    int? gsmSignalPercent,
    String? gsmNetwork,
    double? batteryVoltage,
    String? powerSource,
    bool? vibrationDetected,
    bool? engineRunning,
    String? connectionMode,
    int? timestamp,
  }) {
    return TelemetryModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      satellites: satellites ?? this.satellites,
      hdop: hdop ?? this.hdop,
      gpsFixed: gpsFixed ?? this.gpsFixed,
      gsmCsq: gsmCsq ?? this.gsmCsq,
      gsmSignalPercent: gsmSignalPercent ?? this.gsmSignalPercent,
      gsmNetwork: gsmNetwork ?? this.gsmNetwork,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      powerSource: powerSource ?? this.powerSource,
      vibrationDetected: vibrationDetected ?? this.vibrationDetected,
      engineRunning: engineRunning ?? this.engineRunning,
      connectionMode: connectionMode ?? this.connectionMode,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
