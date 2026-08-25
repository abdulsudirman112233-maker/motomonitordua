import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/telemetry_model.dart';
import '../models/controls_model.dart';
import '../models/log_model.dart';
import '../services/firebase_service.dart';
import '../services/geofence_service.dart';

enum MapTileType { googleRoadmap, googleSatellite, googleTraffic, dark }

class TrackingProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  TelemetryModel _telemetry = TelemetryModel.defaultState();
  ControlsModel _controls = ControlsModel.defaultState();
  List<LogModel> _logs = [];
  final List<LatLng> _trailPoints = [];

  MapTileType _activeMapTile = MapTileType.googleRoadmap;
  bool _autoCenter = true;
  bool _showGeofenceOverlay = true;
  double _liveGeofenceDistance = 0.0;
  bool _isGeofenceBreached = false;
  bool _isEmergencyModalOpen = false;
  String _emergencyModalReason = "";

  // Getters
  TelemetryModel get telemetry => _telemetry;
  ControlsModel get controls => _controls;
  List<LogModel> get logs => _logs;
  List<LatLng> get trailPoints => List.unmodifiable(_trailPoints);
  MapTileType get activeMapTile => _activeMapTile;
  bool get autoCenter => _autoCenter;
  bool get showGeofenceOverlay => _showGeofenceOverlay;
  double get liveGeofenceDistance => _liveGeofenceDistance;
  bool get isGeofenceBreached => _isGeofenceBreached;
  bool get isEmergencyModalOpen => _isEmergencyModalOpen;
  String get emergencyModalReason => _emergencyModalReason;

  TrackingProvider() {
    _initProvider();
  }

  void _initProvider() {
    // Tambahkan log sistem awal
    addLog(LogModel(
      eventType: "SYSTEM_READY",
      message: "Dashboard Pelacak GPS Real-Time Flutter Siap & Terhubung ke Firebase RTDB.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
      latitude: _telemetry.latitude,
      longitude: _telemetry.longitude,
      speed: 0.0,
    ));

    // Mulai listener Firebase
    _firebaseService.startRealtimeListener(
      onTelemetryUpdated: (newTelemetry) {
        _handleTelemetryUpdate(newTelemetry);
      },
      onControlsUpdated: (newControls) {
        _handleControlsUpdate(newControls);
      },
      onLogAdded: (newLog) {
        addLog(newLog);
      },
    );
  }

  void _handleTelemetryUpdate(TelemetryModel newTelemetry) {
    if (newTelemetry.timestamp > 0 && _telemetry.timestamp > 0 &&
        newTelemetry.timestamp < _telemetry.timestamp) return;
    if (newTelemetry.timestamp == 0 && newTelemetry.sequence >= 0 &&
        _telemetry.sequence >= 0 && newTelemetry.sequence < _telemetry.sequence) return;

    // Filter jitter kecepatan GPS jika < 2.5 km/h
    double cleanSpeed = newTelemetry.speed;
    if (cleanSpeed < 2.5) cleanSpeed = 0.0;

    _telemetry = newTelemetry.copyWith(speed: cleanSpeed);

    // Tambahkan titik koordinat ke garis jejak rute
    if (_telemetry.hasTrustedPosition) {
      final newPos = LatLng(_telemetry.latitude, _telemetry.longitude);
      if (_trailPoints.isEmpty || _trailPoints.last != newPos) {
        _trailPoints.add(newPos);
        if (_trailPoints.length > 500) _trailPoints.removeAt(0);
      }
    }

      // Kalkulasi jarak Geofence hanya memakai posisi tepercaya.
      _evaluateGeofence();
    }

    // Periksa pemicu alarm pencurian
    if (_telemetry.vibrationDetected && _controls.armed) {
      triggerEmergencyAlert("GETARAN PAKSA TERDETEKSI SAAT ARMED!");
    }

    notifyListeners();
  }

  void _handleControlsUpdate(ControlsModel newControls) {
    _controls = newControls;
    _evaluateGeofence();
    notifyListeners();
  }

  void _evaluateGeofence() {
    if (!_telemetry.hasTrustedPosition) return;
    if (_controls.anchorLat != null && _controls.anchorLng != null) {
      _liveGeofenceDistance = GeofenceService.calculateDistanceMeters(
        _telemetry.latitude,
        _telemetry.longitude,
        _controls.anchorLat!,
        _controls.anchorLng!,
      );

      final breached = GeofenceService.isBreached(
        _telemetry.latitude,
        _telemetry.longitude,
        _controls.anchorLat!,
        _controls.anchorLng!,
        _controls.geofenceRadius,
      );

      if (breached && _controls.geofenceEnabled) {
        _isGeofenceBreached = true;
        if (_controls.armed && !_isEmergencyModalOpen) {
          triggerEmergencyAlert("KENDARAAN KELUAR DARI RADIUS GEOFENCE AMAN (${_liveGeofenceDistance.toStringAsFixed(1)}m)!");
          if (_controls.autoCutoffGeofence && !_controls.lockEngine) {
            toggleEngineKill(true);
          }
        }
      } else {
        _isGeofenceBreached = false;
      }
    }
  }

  // Action Methods
  Future<void> toggleEngineKill(bool lock) async {
    _controls = _controls.copyWith(lockEngine: lock);
    notifyListeners();

    await _firebaseService.sendControlCommand({'lock_engine': lock});
    addLog(LogModel(
      eventType: lock ? "ENGINE_KILL" : "ENGINE_RESTORE",
      message: lock ? "Perintah Matikan Mesin (Relay Cut-off D3) Dikirim." : "Pengapian Mesin Dipulihkan.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
      latitude: _telemetry.latitude,
      longitude: _telemetry.longitude,
      speed: _telemetry.speed,
    ));
  }

  Future<void> toggleArmSystem(bool arm) async {
    _controls = _controls.copyWith(armed: arm);
    notifyListeners();

    await _firebaseService.sendControlCommand({'armed': arm});
    addLog(LogModel(
      eventType: arm ? "ARM_SYSTEM" : "DISARM_SYSTEM",
      message: arm ? "Sistem Keamanan di-ARM (Siaga Sensor SW-420 Aktif)." : "Sistem Keamanan di-DISARM.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
      latitude: _telemetry.latitude,
      longitude: _telemetry.longitude,
    ));
  }

  Future<void> triggerPanicSiren() async {
    await _firebaseService.sendControlCommand({'trigger_panic': true});
    addLog(LogModel(
      eventType: "PANIC_ALARM",
      message: "Sirene Panic Alarm Diaktifkan Manual dari Dashboard.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
      latitude: _telemetry.latitude,
      longitude: _telemetry.longitude,
    ));
  }

  Future<void> requestEmergencySms() async {
    await _firebaseService.sendControlCommand({'emergency_sms_request': true});
    addLog(LogModel(
      eventType: "SMS_REQUEST",
      message: "Permintaan Kirim SMS SOS Google Maps Dikirim ke SIM800L.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
      latitude: _telemetry.latitude,
      longitude: _telemetry.longitude,
    ));
  }

  Future<void> updateGeofenceRadius(double radius) async {
    _controls = _controls.copyWith(geofenceRadius: radius);
    notifyListeners();

    await _firebaseService.sendControlCommand({'geofence_radius': radius});
    addLog(LogModel(
      eventType: "GEOFENCE_UPDATE",
      message: "Batas Radius Geofence Ditentukan: ${radius.toInt()} Meter.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
    ));
  }

  Future<void> setAnchorToCurrentLocation() async {
    if (!_telemetry.hasTrustedPosition) return;
    _controls = _controls.copyWith(
      anchorLat: _telemetry.latitude,
      anchorLng: _telemetry.longitude,
    );
    notifyListeners();

    await _firebaseService.sendControlCommand({
      'anchor_lat': _telemetry.latitude,
      'anchor_lng': _telemetry.longitude,
    });

    addLog(LogModel(
      eventType: "ANCHOR_SET",
      message: "Titik Parkir Anchor Ditetapkan pada Lat: ${_telemetry.latitude.toStringAsFixed(5)}, Lng: ${_telemetry.longitude.toStringAsFixed(5)}.",
      datetime: DateFormat('HH:mm:ss').format(DateTime.now()),
      latitude: _telemetry.latitude,
      longitude: _telemetry.longitude,
    ));
  }

  Future<void> toggleGeofenceEnabled(bool enable) async {
    _controls = _controls.copyWith(geofenceEnabled: enable);
    notifyListeners();
    await _firebaseService.sendControlCommand({'geofence_enabled': enable});
  }

  Future<void> toggleAutoCutoffGeofence(bool enable) async {
    _controls = _controls.copyWith(autoCutoffGeofence: enable);
    notifyListeners();
    await _firebaseService.sendControlCommand({'auto_cutoff_geofence': enable});
  }

  void switchMapTile(MapTileType type) {
    _activeMapTile = type;
    notifyListeners();
  }

  void toggleAutoCenter(bool value) {
    _autoCenter = value;
    notifyListeners();
  }

  void toggleGeofenceOverlay(bool value) {
    _showGeofenceOverlay = value;
    notifyListeners();
  }

  void clearTrail() {
    _trailPoints.clear();
    _trailPoints.add(LatLng(_telemetry.latitude, _telemetry.longitude));
    notifyListeners();
  }

  void triggerEmergencyAlert(String reason) {
    _isEmergencyModalOpen = true;
    _emergencyModalReason = reason;
    notifyListeners();
  }

  void dismissEmergencyModal() {
    _isEmergencyModalOpen = false;
    _firebaseService.sendControlCommand({'reset_alarm': true, 'trigger_panic': false});
    notifyListeners();
  }

  void addLog(LogModel log) {
    _logs.insert(0, log);
    if (_logs.length > 50) _logs.removeLast();
    notifyListeners();
  }

  @override
  void dispose() {
    _firebaseService.stopListener();
    super.dispose();
  }
}
