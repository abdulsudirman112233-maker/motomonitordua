import 'dart:math';

class GeofenceService {
  /// Menghitung jarak presisi tinggi antara 2 koordinat (Lat/Lng) dalam meter menggunakan rumus Haversine
  static double calculateDistanceMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusMeters = 6371000.0;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }

  /// Memeriksa apakah kendaraan berada di luar radius Geofence aman
  static bool isBreached(
      double currentLat, double currentLng, double anchorLat, double anchorLng, double radiusMeters) {
    final distance = calculateDistanceMeters(currentLat, currentLng, anchorLat, anchorLng);
    return distance > radiusMeters;
  }
}
