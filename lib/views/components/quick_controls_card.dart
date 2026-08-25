import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/tracking_provider.dart';

class QuickControlsCard extends StatelessWidget {
  const QuickControlsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final controls = provider.controls;
    final bool isLocked = controls.lockEngine;
    final bool isArmed = controls.armed;

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
          // Card Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: Color(0xFF00F0FF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "KONTROL JARAK JAUH",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE2E8F0),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                "ESP8266 + SIM800L",
                style: GoogleFonts.jetbrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 0, height: 14),

          // Engine Kill Switch Heavy Action Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFFF3B30).withOpacity(0.15) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLocked ? const Color(0xFFFF3B30) : const Color(0xFF334155),
                width: isLocked ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    cross: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isLocked ? Icons.block_rounded : Icons.power_settings_new_rounded,
                            color: isLocked ? const Color(0xFFFF3B30) : const Color(0xFF00F0FF),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "ENGINE KILL SWITCH",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isLocked ? const Color(0xFFFF3B30) : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLocked ? "Mesin terkunci via Relay D3" : "Memutus pengapian CDI via Relay D3",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.toggleEngineKill(!isLocked);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          !isLocked ? "Perintah: Mesin Telah Dimatikan!" : "Perintah: Pengapian Mesin Dipulihkan.",
                        ),
                        backgroundColor: !isLocked ? const Color(0xFFFF3B30) : const Color(0xFF00E676),
                      ),
                    );
                  },
                  icon: Icon(isLocked ? Icons.key_rounded : Icons.block_rounded, size: 16),
                  label: Text(
                    isLocked ? "PULIHKAN" : "MATIKAN MESIN",
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? const Color(0xFF00E676) : const Color(0xFFFF3B30),
                    foregroundColor: const Color(0xFF0B0F19),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Grid Buttons
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // ARM / DISARM Button
                  SizedBox(
                    width: (constraints.maxWidth - 20) / 3,
                    child: _buildActionButton(
                      icon: isArmed ? Icons.shield_rounded : Icons.shield_outlined,
                      label: isArmed ? "ARMED" : "DISARMED",
                      color: isArmed ? const Color(0xFF00E676) : const Color(0xFF64748B),
                      isActive: isArmed,
                      onTap: () {
                        provider.toggleArmSystem(!isArmed);
                      },
                    ),
                  ),

                  // PANIC SIREN Button
                  SizedBox(
                    width: (constraints.maxWidth - 20) / 3,
                    child: _buildActionButton(
                      icon: Icons.campaign_rounded,
                      label: "PANIC SIREN",
                      color: const Color(0xFFFF9500),
                      isActive: false,
                      onTap: () {
                        provider.triggerPanicSiren();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sirene Panic Alarm Diaktifkan!')),
                        );
                      },
                    ),
                  ),

                  // KIRIM SMS SOS Button
                  SizedBox(
                    width: (constraints.maxWidth - 20) / 3,
                    child: _buildActionButton(
                      icon: Icons.sms_rounded,
                      label: "KIRIM SMS SOS",
                      color: const Color(0xFF00F0FF),
                      isActive: false,
                      onTap: () {
                        provider.requestEmergencySms();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Permintaan SMS SOS dikirim ke SIM800L!')),
                        );
                      },
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.18) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? color : const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
