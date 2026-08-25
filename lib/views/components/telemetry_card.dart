import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/tracking_provider.dart';

class TelemetryCard extends StatelessWidget {
  const TelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final telemetry = provider.telemetry;
    final controls = provider.controls;

    final double speed = telemetry.speed;
    final bool isLocked = controls.lockEngine;
    final bool isVibrating = telemetry.vibrationDetected;

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
          Row(
            children: [
              const Icon(Icons.memory_rounded, color: Color(0xFF00F0FF), size: 18),
              const SizedBox(width: 8),
              Text(
                "DATA TELEMETRI SENSOR",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE2E8F0),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid Telemetry Items
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Kecepatan Item
                  SizedBox(
                    width: itemWidth,
                    child: _buildStatTile(
                      icon: Icons.speed_rounded,
                      label: "Kecepatan",
                      value: "${speed.toStringAsFixed(0)} km/h",
                      valueColor: speed > 80.0
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF00F0FF),
                    ),
                  ),

                  // Kondisi Mesin Item
                  SizedBox(
                    width: itemWidth,
                    child: _buildStatTile(
                      icon: Icons.key_rounded,
                      label: "Kondisi Mesin",
                      value: isLocked
                          ? "CUT-OFF"
                          : (telemetry.engineRunning || speed >= 3.5 ? "BERJALAN" : "MATI (OFF)"),
                      valueColor: isLocked
                          ? const Color(0xFFFF3B30)
                          : (telemetry.engineRunning || speed >= 3.5
                              ? const Color(0xFF00E676)
                              : const Color(0xFF94A3B8)),
                    ),
                  ),

                  // Sensor Getar Item
                  SizedBox(
                    width: itemWidth,
                    child: _buildStatTile(
                      icon: Icons.notifications_active_rounded,
                      label: "Status Getaran",
                      value: isVibrating ? "GETARAN TERDETEKSI" : "STABIL (AMAN)",
                      valueColor: isVibrating ? const Color(0xFFFF3B30) : const Color(0xFF00E676),
                    ),
                  ),

                  // Tegangan Aki Item
                  SizedBox(
                    width: itemWidth,
                    child: _buildStatTile(
                      icon: Icons.battery_charging_full_rounded,
                      label: "Tegangan Aki",
                      value: "${telemetry.batteryVoltage.toStringAsFixed(1)} V",
                      valueColor: telemetry.batteryVoltage < 11.2
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),

                  // Satelit GPS Item
                  SizedBox(
                    width: itemWidth,
                    child: _buildStatTile(
                      icon: Icons.satellite_alt_rounded,
                      label: "Satelit GPS",
                      value: "${telemetry.satellites} Sats (${telemetry.hdop.toStringAsFixed(1)} HDOP)",
                      valueColor: const Color(0xFFE2E8F0),
                    ),
                  ),

                  // Sinyal GSM Item
                  SizedBox(
                    width: itemWidth,
                    child: _buildStatTile(
                      icon: Icons.cell_tower_rounded,
                      label: "Sinyal GSM",
                      value: "${telemetry.gsmSignalPercent}% (CSQ ${telemetry.gsmCsq})",
                      valueColor: const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetbrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
