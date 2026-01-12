import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './login_screen.dart';
import './machine_management_screen.dart';
import '../core/constants.dart';
import '../widgets/muscle_tag.dart';
import '../widgets/custom_bottom_nav.dart'; // <--- Import the widget

class BodyMapScreen extends StatefulWidget {
  final String userId;
  final bool isVerified;

  const BodyMapScreen({
    super.key,
    this.userId = '',
    this.isVerified = false,
  });

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  // 0 = Anterior, 1 = Posterior, 2 = Create (only if verified)
  int _currentViewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isAnterior = _currentViewIndex == 0;

    // If verified and "Create" tab selected -> show create screen
    if (widget.isVerified && _currentViewIndex == 2) {
      return MachineManagementScreen(
        userId: widget.userId,
        isVerified: widget.isVerified, // Pass this so the navbar knows to show 3 items
        onTabSelected: (index) {
          // This allows the MachineManagementScreen navbar to switch views
          setState(() => _currentViewIndex = index);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.grey),
          onPressed: () async {
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (_) {}

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          )
        ],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAnterior ? "ANTERIOR VIEW" : "POSTERIOR VIEW",
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.5,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isAnterior ? "FRONT MUSCLES" : "BACK MUSCLES",
              style: const TextStyle(
                fontSize: 28,
                fontFamily: 'Impact',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),

      // --- USE THE CUSTOM NAVBAR ---
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentViewIndex,
        isVerified: widget.isVerified,
        onTap: (index) => setState(() => _currentViewIndex = index),
      ),

      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  isAnterior ? 'assets/frontmuscle.png' : 'assets/backmuscle.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Text(
                          "Image Missing (Check Assets)",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),

                if (isAnterior) ..._buildAnteriorTags() else ..._buildPosteriorTags(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnteriorTags() {
    return const [
      Align(alignment: Alignment(-0.85, -0.8), child: MuscleTag(label: "Chest", isActive: true)),
      Align(alignment: Alignment(-0.85, -0.46), child: MuscleTag(label: "Front Shoulders", isActive: false)),
      Align(alignment: Alignment(-0.85, -0.27), child: MuscleTag(label: "Biceps", isActive: false)),
      Align(alignment: Alignment(-0.85, -0.08), child: MuscleTag(label: "Arms", isActive: false)),
      Align(alignment: Alignment(-0.85, 0.35), child: MuscleTag(label: "Quads", isActive: false)),
      Align(alignment: Alignment(0.85, -0.55), child: MuscleTag(label: "Side Shoulders", isActive: false)),
      Align(alignment: Alignment(0.85, -0.15), child: MuscleTag(label: "Abs", isActive: false)),
      Align(alignment: Alignment(0.85, 0.67), child: MuscleTag(label: "Shins", isActive: false)),
    ];
  }

  List<Widget> _buildPosteriorTags() {
    return const [
      Align(alignment: Alignment(-0.85, -0.8), child: MuscleTag(label: "Neck", isActive: true)),
      Align(alignment: Alignment(-0.85, -0.5), child: MuscleTag(label: "Rear Shoulders", isActive: false)),
      Align(alignment: Alignment(-0.85, -0.3), child: MuscleTag(label: "Triceps", isActive: false)),
      Align(alignment: Alignment(-0.85, -0.08), child: MuscleTag(label: "Lower Back", isActive: false)),
      Align(alignment: Alignment(0.85, -0.75), child: MuscleTag(label: "Traps", isActive: false)),
      Align(alignment: Alignment(0.85, -0.53), child: MuscleTag(label: "Middle Back", isActive: false)),
      Align(alignment: Alignment(0.85, -0.35), child: MuscleTag(label: "Lats", isActive: false)),
      Align(alignment: Alignment(0.85, 0.15), child: MuscleTag(label: "Glutes", isActive: false)),
      Align(alignment: Alignment(0.85, 0.46), child: MuscleTag(label: "Hamstrings", isActive: false)),
      Align(alignment: Alignment(0.85, 0.77), child: MuscleTag(label: "Calves", isActive: false)),
    ];
  }
}