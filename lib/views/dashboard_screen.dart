import 'package:flutter/material.dart';
import 'components/top_navbar.dart';
import 'components/map_view_widget.dart';
import 'components/quick_controls_card.dart';
import 'components/geofence_card.dart';
import 'components/telemetry_card.dart';
import 'components/logs_card.dart';
import 'components/emergency_alarm_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          // Background subtle gradient glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.6),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1E1B4B),
                    Color(0xFF0B0F19),
                  ],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Navbar
                  const TopNavbar(),
                  const SizedBox(height: 16),

                  // Responsive Main Grid
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWideScreen = constraints.maxWidth >= 900;

                        if (isWideScreen) {
                          // Desktop / Web / Tablet 2-Column Grid
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Interactive Map & Activity Logs
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: const [
                                    Expanded(
                                      flex: 6,
                                      child: MapViewWidget(),
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      flex: 4,
                                      child: SingleChildScrollView(
                                        child: LogsCard(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Right Column: Controls, Geofence & Telemetry
                              Expanded(
                                flex: 4,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: const [
                                      QuickControlsCard(),
                                      SizedBox(height: 16),
                                      GeofenceCard(),
                                      SizedBox(height: 16),
                                      TelemetryCard(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Mobile Single Column Stack
                          return SingleChildScrollView(
                            child: Column(
                              children: const [
                                SizedBox(
                                  height: 380,
                                  child: MapViewWidget(),
                                ),
                                SizedBox(height: 16),
                                QuickControlsCard(),
                                SizedBox(height: 16),
                                GeofenceCard(),
                                SizedBox(height: 16),
                                TelemetryCard(),
                                SizedBox(height: 16),
                                LogsCard(),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Emergency Theft Alarm Modal Overlay
          const EmergencyAlarmModal(),
        ],
      ),
    );
  }
}
