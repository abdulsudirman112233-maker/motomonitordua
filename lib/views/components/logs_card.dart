import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/tracking_provider.dart';

class LogsCard extends StatelessWidget {
  const LogsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final logs = provider.logs;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF00F0FF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "RIWAYAT LOG AKTIVITAS & KEAMANAN REAL-TIME",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE2E8F0),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                "Auto-sync Firebase RTDB",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Log List View
          logs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      "Belum ada log aktivitas.",
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length > 15 ? 15 : logs.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFF1E293B), height: 1),
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    Color badgeColor = const Color(0xFF00F0FF);
                    if (log.eventType.contains('THEFT') ||
                        log.eventType.contains('ALARM') ||
                        log.eventType.contains('KILL')) {
                      badgeColor = const Color(0xFFFF3B30);
                    } else if (log.eventType.contains('ARM') || log.eventType.contains('RESTORE')) {
                      badgeColor = const Color(0xFF00E676);
                    } else if (log.eventType.contains('WARN') || log.eventType.contains('GEOFENCE')) {
                      badgeColor = const Color(0xFFFF9500);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time Badge
                          Text(
                            log.datetime,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Event Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeColor.withOpacity(0.4)),
                            ),
                            child: Text(
                              log.eventType,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Message Text
                          Expanded(
                            child: Text(
                              log.message,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
