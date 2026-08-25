import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/tracking_provider.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({super.key});

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final telemetry = provider.telemetry;
    final controls = provider.controls;
    final currentPos = LatLng(telemetry.latitude, telemetry.longitude);

    // Otomatis fokuskan ke kendaraan jika AutoCenter aktif
    if (provider.autoCenter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(currentPos, _mapController.camera.zoom);
      });
    }

    String tileUrl;
    switch (provider.activeMapTile) {
      case MapTileType.googleSatellite:
        tileUrl = 'https://mt1.google.com/vt/lyrs=y&hl=id&gl=ID&x={x}&y={y}&z={z}';
        break;
      case MapTileType.googleTraffic:
        tileUrl = 'https://mt1.google.com/vt/lyrs=m,traffic&hl=id&gl=ID&x={x}&y={y}&z={z}';
        break;
      case MapTileType.dark:
        tileUrl = 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
        break;
      case MapTileType.googleRoadmap:
      default:
        tileUrl = 'https://mt1.google.com/vt/lyrs=m&hl=id&gl=ID&x={x}&y={y}&z={z}';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header Bar & Controls Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Address / GPS Coordinates Display
                  const Icon(Icons.location_on_rounded, color: Color(0xFF00F0FF), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Lat: ${telemetry.latitude.toStringAsFixed(5)}, Lng: ${telemetry.longitude.toStringAsFixed(5)}",
                    style: GoogleFonts.jetbrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Toolbar Action Buttons
                  _buildToolbarButton(
                    icon: Icons.my_location_rounded,
                    label: "Auto Center",
                    isActive: provider.autoCenter,
                    onTap: () {
                      provider.toggleAutoCenter(!provider.autoCenter);
                      if (!provider.autoCenter) {
                        _mapController.move(currentPos, 18);
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  _buildToolbarButton(
                    icon: Icons.shield_outlined,
                    label: "Geofence Overlay",
                    isActive: provider.showGeofenceOverlay,
                    onTap: () => provider.toggleGeofenceOverlay(!provider.showGeofenceOverlay),
                  ),
                  const SizedBox(width: 8),

                  _buildToolbarButton(
                    icon: Icons.map_rounded,
                    label: "Roadmap",
                    isActive: provider.activeMapTile == MapTileType.googleRoadmap,
                    onTap: () => provider.switchMapTile(MapTileType.googleRoadmap),
                  ),
                  const SizedBox(width: 8),

                  _buildToolbarButton(
                    icon: Icons.public_rounded,
                    label: "Satelit",
                    isActive: provider.activeMapTile == MapTileType.googleSatellite,
                    onTap: () => provider.switchMapTile(MapTileType.googleSatellite),
                  ),
                  const SizedBox(width: 8),

                  _buildToolbarButton(
                    icon: Icons.traffic_rounded,
                    label: "Lalu Lintas",
                    isActive: provider.activeMapTile == MapTileType.googleTraffic,
                    onTap: () => provider.switchMapTile(MapTileType.googleTraffic),
                  ),
                  const SizedBox(width: 8),

                  _buildToolbarButton(
                    icon: Icons.dark_mode_rounded,
                    label: "Dark",
                    isActive: provider.activeMapTile == MapTileType.dark,
                    onTap: () => provider.switchMapTile(MapTileType.dark),
                  ),
                  const SizedBox(width: 8),

                  _buildToolbarButton(
                    icon: Icons.cleaning_services_rounded,
                    label: "Reset Jejak",
                    isActive: false,
                    onTap: () => provider.clearTrail(),
                  ),
                ],
              ),
            ),
          ),

          // Interactive Map Area
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentPos,
                  initialZoom: 18.0,
                  maxZoom: 20.0,
                  minZoom: 4.0,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && provider.autoCenter) {
                      provider.toggleAutoCenter(false);
                    }
                  },
                ),
                children: [
                  // Tile Layer
                  TileLayer(
                    urlTemplate: tileUrl,
                    subdomains: const ['0', '1', '2', '3'],
                    userAgentPackageName: 'com.example.gps_tracker_flutter',
                  ),

                  // Route Polyline Trail Layer
                  if (provider.trailPoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: provider.trailPoints,
                          strokeWidth: 4.0,
                          color: const Color(0xFF00F0FF).withOpacity(0.85),
                        ),
                      ],
                    ),

                  // Geofence Circle Overlay Layer
                  if (provider.showGeofenceOverlay && controls.anchorLat != null && controls.anchorLng != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(controls.anchorLat!, controls.anchorLng!),
                          radius: controls.geofenceRadius,
                          useRadiusInMeter: true,
                          color: const Color(0xFF7928CA).withOpacity(0.20),
                          borderColor: const Color(0xFFC084FC),
                          borderStrokeWidth: 2.0,
                        ),
                      ],
                    ),

                  // Vehicle Marker Layer
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentPos,
                        width: 50,
                        height: 50,
                        child: Transform.rotate(
                          angle: (telemetry.heading * math.pi / 180.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: provider.isGeofenceBreached
                                  ? const Color(0xFFFF3B30)
                                  : const Color(0xFF00F0FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (provider.isGeofenceBreached
                                          ? const Color(0xFFFF3B30)
                                          : const Color(0xFF00F0FF))
                                      .withOpacity(0.6),
                                  blurRadius: 14,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.two_wheeler_rounded,
                              color: Color(0xFF0B0F19),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF00F0FF) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00F0FF).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? const Color(0xFF00F0FF) : const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
