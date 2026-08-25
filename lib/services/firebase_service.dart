import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/telemetry_model.dart';
import '../models/controls_model.dart';
import '../models/log_model.dart';

class FirebaseService {
  final String databaseUrl = "https://motor-monitor-9f391-default-rtdb.asia-southeast1.firebasedatabase.app";
  final String vehicleId = "vehicle_01";

  Timer? _pollingTimer;

  /// Memulai sinkronisasi berkala (polling / SSE) ke Firebase RTDB
  void startRealtimeListener({
    required Function(TelemetryModel) onTelemetryUpdated,
    required Function(ControlsModel) onControlsUpdated,
    required Function(LogModel) onLogAdded,
  }) {
    _fetchData(onTelemetryUpdated, onControlsUpdated, onLogAdded);

    // Polling setiap 1.5 detik untuk latensi rendah
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _fetchData(onTelemetryUpdated, onControlsUpdated, onLogAdded);
    });
  }

  void stopListener() {
    _pollingTimer?.cancel();
  }

  Future<void> _fetchData(
    Function(TelemetryModel) onTelemetryUpdated,
    Function(ControlsModel) onControlsUpdated,
    Function(LogModel) onLogAdded,
  ) async {
    try {
      final url = Uri.parse('$databaseUrl/vehicles/$vehicleId.json');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 && response.body != 'null') {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('telemetry') && data['telemetry'] is Map) {
          final telemetry = TelemetryModel.fromJson(Map<String, dynamic>.from(data['telemetry']));
          onTelemetryUpdated(telemetry);
        }

        if (data.containsKey('controls') && data['controls'] is Map) {
          final controls = ControlsModel.fromJson(Map<String, dynamic>.from(data['controls']));
          onControlsUpdated(controls);
        }
      }
    } catch (e) {
      // Menangani error koneksi secara efisien tanpa crash
    }
  }

  /// Mengirimkan perintah kontrol (PATCH) ke Firebase Realtime Database
  Future<bool> sendControlCommand(Map<String, dynamic> commandData) async {
    try {
      final url = Uri.parse('$databaseUrl/vehicles/$vehicleId/controls.json');
      final payload = Map<String, dynamic>.from(commandData)
        ..['last_command_time'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Mengirimkan catatan log baru ke Firebase
  Future<void> pushLog(LogModel log) async {
    try {
      final url = Uri.parse('$databaseUrl/vehicles/$vehicleId/logs.json');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(log.toJson()),
      );
    } catch (e) {
      // Error dimuat secara lokal jika offline
    }
  }
}
