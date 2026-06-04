import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../widgets/youtube_player_widget.dart';
import '../widgets/video_player_widget.dart';

class MachineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> machineData;

  const MachineDetailScreen({super.key, required this.machineData});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  late Future<Map<String, dynamic>?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchMachineDetails();
  }

  bool _isYouTubeUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') || lower.contains('youtu.be') || lower.contains('/shorts/');
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm') || lower.endsWith('.mkv');
  }

  Future<Map<String, dynamic>?> _fetchMachineDetails() async {
    final response = await Supabase.instance.client
        .from('machine_detail')
        .select()
        .eq('machine_id', widget.machineData['id'])
        .maybeSingle();

    final creatorId = widget.machineData['creator_id'];
    String? creatorName;
    if (creatorId != null) {
      final creatorRow = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', creatorId)
          .maybeSingle();
      creatorName = creatorRow?['username'];
    }

    final result = <String, dynamic>{};
    if (response != null) result.addAll(response);
    result['_creator_name'] = creatorName;
    return result;
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch video')),
        );
      }
    }
  }


  String _formatSetsReps(String raw) {
    final regex = RegExp(r'^(\d+)\s*x\s*(\d+)$');
    final match = regex.firstMatch(raw.trim());

    if (match != null) {
      final sets = match.group(1);
      final reps = match.group(2);
      return "$sets Sets x $reps Reps (Recommended)";
    }
    
    return raw; 
  }

  @override
  Widget build(BuildContext context) {
    final machineName = widget.machineData['name'] ?? 'Unknown Machine';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("DETAILS",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
                color: Colors.white)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          final detail = snapshot.data;

          final description = detail?['description'] ?? "No description available yet.";
          final instructionsText = detail?['instructions'] ?? "";
          final difficulty = detail?['difficulty'] ?? "General";
          final creatorName = detail?['_creator_name'] as String?;

          final rawSetsReps = detail?['sets_reps'] ?? "3x12";
          final formattedSetsReps = _formatSetsReps(rawSetsReps);

          final videoUrl = detail?['video'];

          final List<String> instructionSteps = 
              instructionsText.toString().split('\n').where((s) => s.trim().isNotEmpty).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Video Player
                  if (videoUrl != null && videoUrl.toString().isNotEmpty) ...[
                    Builder(builder: (_) {
                      final v = videoUrl.toString();
                      if (_isYouTubeUrl(v)) {
                        return Column(children: [YouTubeVideoPlayer(videoUrl: v), const SizedBox(height: 25)]);
                      }

                      if (_isVideoUrl(v)) {
                        return Column(children: [VideoPlayerWidget(videoUrl: v), const SizedBox(height: 25)]);
                      }

                      // fallback: show a button to launch externally
                      return Column(children: [
                        ElevatedButton.icon(
                          onPressed: () => _launchVideo(v),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Video'),
                        ),
                        const SizedBox(height: 25),
                      ]);
                    }),
                  ],

                // Header Info
                Text(
                  machineName,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.3),
                ),

                if (creatorName != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, color: kMutedText, size: 15),
                      const SizedBox(width: 5),
                      const Text('Created by ', style: TextStyle(color: kMutedText, fontSize: 13)),
                      Text(
                        creatorName,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 18),

                // Stat chips
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: 'Difficulty',
                        value: difficulty,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.replay_rounded,
                        label: 'Sets & Reps',
                        value: formattedSetsReps.replaceAll(' (Recommended)', ''),
                        highlight: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Description
                const Text("DESCRIPTION", style: kSectionLabel),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      height: 1.6,
                      fontSize: 15),
                ),

                // Instructions
                if (instructionSteps.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  const Text("INSTRUCTIONS", style: kSectionLabel),
                  const SizedBox(height: 18),
                  ...instructionSteps.asMap().entries.map((entry) {
                    return _buildStep(
                      entry.key + 1,
                      entry.value,
                      isLast: entry.key == instructionSteps.length - 1,
                    );
                  }),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(int number, String text, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor.withAlpha(120)),
                ),
                child: Text(
                  "$number",
                  style: const TextStyle(
                      fontSize: 13,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Connecting line between steps
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.white.withAlpha(20),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 3),
              child: Text(text,
                  style: TextStyle(
                      height: 1.45,
                      fontSize: 15,
                      color: Colors.white.withAlpha(230))),
            ),
          ),
        ],
      ),
    );
  }
}

// Compact stat card used in the detail header (difficulty / sets & reps).
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: highlight ? kPrimaryColor : kMutedText),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                    color: kMutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: highlight ? kPrimaryColor : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}