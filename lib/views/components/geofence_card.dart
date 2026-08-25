import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/tracking_provider.dart';

class GeofenceCard extends StatelessWidget {
  const GeofenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final controls = provider.controls;
    final liveDistance = provider.liveGeofenceDistance;
    final isBreached = provider.isGeofenceBreached;
    final geofenceLimit = controls.geofenceRadius;

    final double progressFraction = (geofenceLimit > 0)
        ? (liveDistance / geofenceLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.85),
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
        cross: CrossAxisAlignment.start,
        children: [
          // Header & Toggle Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.polyline_rounded, color: Color(0xFFC084FC), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "PEMBATASAN JARAK (GEOFENCE)",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE2E8F0),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Switch(
                value: controls.geofenceEnabled,
                onChanged: (val) => provider.toggleGeofenceEnabled(val),
                activeColor: const Color(0xFFC084FC),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Live Distance Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isBreached
                  ? const Color(0xFFFF3B30).withOpacity(0.18)
                  : const Color(0xFF7928CA).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBreached ? const Color(0xFFFF3B30) : const Color(0xFFC084FC).withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isBreached ? Icons.warning_amber_rounded : Icons.shield_rounded,
                  color: isBreached ? const Color(0xFFFF3B30) : const Color(0xFFC084FC),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    cross: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBreached ? "PAGAR VIRTUAL TERLANGGAR (ALERT!)" : "PAGAR VIRTUAL AKTIF (AMAN)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isBreached ? const Color(0xFFFF3B30) : const Color(0xFFC084FC),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8)),
                          children: [
                            const TextSpan(text: "Jarak dari Parkir: "),
                            TextSpan(
                              text: "${liveDistance.toStringAsFixed(1)} m ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isBreached ? const Color(0xFFFF3B30) : const Color(0xFF00F0FF),
                              ),
                            ),
                            const TextSpan(text: "/ Batas: "),
                            TextSpan(
                              text: "${geofenceLimit.toInt()} m",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Distance Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(
                isBreached ? const Color(0xFFFF3B30) : const Color(0xFF00F0FF),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Radius Control Slider & Preset Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Batas Radius Aman:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  "${geofenceLimit.toInt()} Meter",
                  style: GoogleFonts.jetbrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00F0FF),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: geofenceLimit.clamp(10.0, 500.0),
            min: 10.0,
            max: 500.0,
            divisions: 98,
            activeColor: const Color(0xFFC084FC),
            inactiveColor: const Color(0xFF1E293B),
            onChanged: (val) {
              provider.updateGeofenceRadius(val);
            },
          ),

          // Quick Presets Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [20, 50, 100, 250, 500, 1000].map((r) {
                final double radiusVal = r.toDouble();
                final bool isSelected = (geofenceLimit == radiusVal);

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => provider.updateGeofenceRadius(radiusVal),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFC084FC).withOpacity(0.2) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFC084FC) : const Color(0xFF334155),
                        ),
                      ),
                      child: Text(
                        r >= 1000 ? "${r ~/ 1000} km" : "${r}m",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFC084FC) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Anchor Button & Auto Cutoff Checkbox
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.setAnchorToCurrentLocation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Titik Parkir Anchor telah diperbarui!')),
                );
              },
              icon: const Icon(Icons.my_location_rounded, size: 16),
              label: Text(
                "Tetapkan Titik Parkir Saat Ini",
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7928CA).withOpacity(0.2),
                foregroundColor: const Color(0xFFC084FC),
                side: const BorderSide(color: Color(0xFFC084FC)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Checkbox(
                value: controls.autoCutoffGeofence,
                onChanged: (val) => provider.toggleAutoCutoffGeofence(val ?? false),
                activeColor: const Color(0xFFFF9500),
              ),
              Expanded(
                child: Text(
                  "Matikan Mesin Otomatis jika keluar radius",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
