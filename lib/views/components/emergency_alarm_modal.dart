import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/tracking_provider.dart';

class EmergencyAlarmModal extends StatelessWidget {
  const EmergencyAlarmModal({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);

    if (!provider.isEmergencyModalOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          width: 420,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF3B30), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3B30).withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 4,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alarm Animated Warning Icon Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF3B30), width: 2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF3B30),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "PERINGATAN PENCURIAN!",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF3B30),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                provider.emergencyModalReason.isNotEmpty
                    ? provider.emergencyModalReason
                    : "Sensor getar SW-420 mendeteksi gerakan paksa saat sistem terkunci (ARMED).",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "Sirene alarm kendaraan aktif dan notifikasi darurat telah dikirim ke nomor pemilik.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 24),

              // Modal Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.dismissEmergencyModal();
                      },
                      icon: const Icon(Icons.volume_off_rounded, size: 16),
                      label: Text(
                        "Matikan Sirene",
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE2E8F0),
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.toggleEngineKill(true);
                        provider.dismissEmergencyModal();
                      },
                      icon: const Icon(Icons.block_rounded, size: 16),
                      label: Text(
                        "Matikan Mesin",
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
