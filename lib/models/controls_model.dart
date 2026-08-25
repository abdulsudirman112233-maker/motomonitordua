class ControlsModel {
  final bool lockEngine;
  final bool armed;
  final bool triggerPanic;
  final bool findVehicle;
  final bool emergencySmsRequest;
  final bool resetAlarm;
  final bool geofenceEnabled;
  final double geofenceRadius;
  final double? anchorLat;
  final double? anchorLng;
  final bool autoCutoffGeofence;
  final int lastCommandTime;

  ControlsModel({
    required this.lockEngine,
    required this.armed,
    required this.triggerPanic,
    required this.findVehicle,
    required this.emergencySmsRequest,
    required this.resetAlarm,
    required this.geofenceEnabled,
    required this.geofenceRadius,
    this.anchorLat,
    this.anchorLng,
    required this.autoCutoffGeofence,
    required this.lastCommandTime,
  });

  factory ControlsModel.defaultState() {
    return ControlsModel(
      lockEngine: false,
      armed: true,
      triggerPanic: false,
      findVehicle: false,
      emergencySmsRequest: false,
      resetAlarm: false,
      geofenceEnabled: true,
      geofenceRadius: 20.0,
      anchorLat: -5.460095,
      anchorLng: 122.616677,
      autoCutoffGeofence: true,
      lastCommandTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  factory ControlsModel.fromJson(Map<String, dynamic> json) {
    return ControlsModel(
      lockEngine: json['lock_engine'] ?? json['engine_locked'] ?? false,
      armed: json['armed'] ?? true,
      triggerPanic: json['trigger_panic'] ?? false,
      findVehicle: json['find_vehicle'] ?? false,
      emergencySmsRequest: json['emergency_sms_request'] ?? false,
      resetAlarm: json['reset_alarm'] ?? false,
      geofenceEnabled: json['geofence_enabled'] ?? true,
      geofenceRadius: (json['geofence_radius'] as num?)?.toDouble() ?? 20.0,
      anchorLat: (json['anchor_lat'] as num?)?.toDouble(),
      anchorLng: (json['anchor_lng'] as num?)?.toDouble(),
      autoCutoffGeofence: json['auto_cutoff_geofence'] ?? true,
      lastCommandTime: (json['last_command_time'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lock_engine': lockEngine,
      'armed': armed,
      'trigger_panic': triggerPanic,
      'find_vehicle': findVehicle,
      'emergency_sms_request': emergencySmsRequest,
      'reset_alarm': resetAlarm,
      'geofence_enabled': geofenceEnabled,
      'geofence_radius': geofenceRadius,
      'anchor_lat': anchorLat,
      'anchor_lng': anchorLng,
      'auto_cutoff_geofence': autoCutoffGeofence,
      'last_command_time': lastCommandTime,
    };
  }

  ControlsModel copyWith({
    bool? lockEngine,
    bool? armed,
    bool? triggerPanic,
    bool? findVehicle,
    bool? emergencySmsRequest,
    bool? resetAlarm,
    bool? geofenceEnabled,
    double? geofenceRadius,
    double? anchorLat,
    double? anchorLng,
    bool? autoCutoffGeofence,
    int? lastCommandTime,
  }) {
    return ControlsModel(
      lockEngine: lockEngine ?? this.lockEngine,
      armed: armed ?? this.armed,
      triggerPanic: triggerPanic ?? this.triggerPanic,
      findVehicle: findVehicle ?? this.findVehicle,
      emergencySmsRequest: emergencySmsRequest ?? this.emergencySmsRequest,
      resetAlarm: resetAlarm ?? this.resetAlarm,
      geofenceEnabled: geofenceEnabled ?? this.geofenceEnabled,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      anchorLat: anchorLat ?? this.anchorLat,
      anchorLng: anchorLng ?? this.anchorLng,
      autoCutoffGeofence: autoCutoffGeofence ?? this.autoCutoffGeofence,
      lastCommandTime: lastCommandTime ?? this.lastCommandTime,
    );
  }
}
