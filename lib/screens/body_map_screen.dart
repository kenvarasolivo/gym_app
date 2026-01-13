import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import './login_screen.dart';
import './machine_management_screen.dart';
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
  // Set of muscle groups that have machines in the DB
  Set<String> _availableGroups = {};
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchAvailableGroups();
    // Poll periodically so UI updates without hot reload when DB changes
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAvailableGroups());
  }

  Future<void> _fetchAvailableGroups() async {
    try {
      final data = await Supabase.instance.client.from('machine_list').select('musclegroup');
      final groups = data
          .map((e) => (e['musclegroup'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (mounted) setState(() => _availableGroups = groups);
        } catch (e) {
      debugPrint('Error fetching available groups: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

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

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            } catch (_) {}
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
    return [
      Align(alignment: Alignment(-0.85, -0.8), child: MuscleTag(label: "Chest", isActive: _availableGroups.contains('Chest'))),
      Align(alignment: Alignment(-0.85, -0.46), child: MuscleTag(label: "Front Shoulders", isActive: _availableGroups.contains('Front Shoulders'))),
      Align(alignment: Alignment(-0.85, -0.27), child: MuscleTag(label: "Biceps", isActive: _availableGroups.contains('Biceps'))),
      Align(alignment: Alignment(-0.85, -0.08), child: MuscleTag(label: "Arms", isActive: _availableGroups.contains('Arms'))),
      Align(alignment: Alignment(-0.85, 0.35), child: MuscleTag(label: "Quads", isActive: _availableGroups.contains('Quads'))),
      Align(alignment: Alignment(0.85, -0.55), child: MuscleTag(label: "Side Shoulders", isActive: _availableGroups.contains('Side Shoulders'))),
      Align(alignment: Alignment(0.85, -0.15), child: MuscleTag(label: "Abs", isActive: _availableGroups.contains('Abs'))),
      Align(alignment: Alignment(0.85, 0.67), child: MuscleTag(label: "Shins", isActive: _availableGroups.contains('Shins'))),
    ];
  }

  List<Widget> _buildPosteriorTags() {
    return [
      Align(alignment: Alignment(-0.85, -0.8), child: MuscleTag(label: "Neck", isActive: _availableGroups.contains('Neck'))),
      Align(alignment: Alignment(-0.85, -0.5), child: MuscleTag(label: "Rear Shoulders", isActive: _availableGroups.contains('Rear Shoulders'))),
      Align(alignment: Alignment(-0.85, -0.3), child: MuscleTag(label: "Triceps", isActive: _availableGroups.contains('Triceps'))),
      Align(alignment: Alignment(-0.85, -0.08), child: MuscleTag(label: "Lower Back", isActive: _availableGroups.contains('Lower Back'))),
      Align(alignment: Alignment(0.85, -0.75), child: MuscleTag(label: "Traps", isActive: _availableGroups.contains('Traps'))),
      Align(alignment: Alignment(0.85, -0.53), child: MuscleTag(label: "Middle Back", isActive: _availableGroups.contains('Middle Back'))),
      Align(alignment: Alignment(0.85, -0.35), child: MuscleTag(label: "Lats", isActive: _availableGroups.contains('Lats'))),
      Align(alignment: Alignment(0.85, 0.15), child: MuscleTag(label: "Glutes", isActive: _availableGroups.contains('Glutes'))),
      Align(alignment: Alignment(0.85, 0.46), child: MuscleTag(label: "Hamstrings", isActive: _availableGroups.contains('Hamstrings'))),
      Align(alignment: Alignment(0.85, 0.77), child: MuscleTag(label: "Calves", isActive: _availableGroups.contains('Calves'))),
    ];
  }
}