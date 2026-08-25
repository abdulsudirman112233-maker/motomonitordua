import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/tracking_provider.dart';

class TopNavbar extends StatelessWidget {
  const TopNavbar({super.key});

  Future<void> _openGoogleMaps(BuildContext context, double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final telemetry = provider.telemetry;
    final controls = provider.controls;

    final bool isOnline = telemetry.connectionMode != 'OFFLINE';
    final bool isArmed = controls.armed;
    final bool isLocked = controls.lockEngine;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            cross: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              // Brand & Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F0FF).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
                    ),
                    child: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF00F0FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    cross: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SMART VEHICLE IOT TRACKER",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isCompact ? 13 : 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00F0FF),
                          letterSpacing: 1.1,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.two_wheeler_rounded, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            "Yamaha Jupiter Z1",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Status Badges Group
              Wrap(
                spacing: 8,
                runSpacing: 8,
                cross: WrapCrossAlignment.center,
                children: [
                  // Connection Badge
                  _buildBadge(
                    icon: isOnline ? Icons.wifi : Icons.wifi_off,
                    label: telemetry.connectionMode,
                    color: isOnline ? const Color(0xFF00E676) : const Color(0xFFFF3B30),
                  ),

                  // Security Mode Badge
                  _buildBadge(
                    icon: isArmed ? Icons.shield_rounded : Icons.shield_outlined,
                    label: isArmed ? "ARMED" : "DISARMED",
                    color: isArmed ? const Color(0xFF00E676) : const Color(0xFF94A3B8),
                  ),

                  // Engine Status Badge
                  _buildBadge(
                    icon: isLocked ? Icons.block_rounded : Icons.bolt_rounded,
                    label: isLocked ? "CUT-OFF" : "ENGINE NORMAL",
                    color: isLocked ? const Color(0xFFFF3B30) : const Color(0xFF00F0FF),
                  ),

                  // Google Maps Quick Button
                  ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(context, telemetry.latitude, telemetry.longitude),
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: Text(
                      "Google Maps",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F0FF).withOpacity(0.15),
                      foregroundColor: const Color(0xFF00F0FF),
                      side: const BorderSide(color: Color(0xFF00F0FF)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.jetbrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
