import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

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

  Future<Map<String, dynamic>?> _fetchMachineDetails() async {
    final response = await Supabase.instance.client
        .from('machine_detail')
        .select()
        .eq('machine_id', widget.machineData['id'])
        .maybeSingle();
    return response;
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

  // --- NEW: Helper to format "4x12" into "4 Sets x 12 Reps..." ---
  String _formatSetsReps(String raw) {
    // Regex to look for "Number x Number" (e.g., 4x12 or 4 x 12)
    final regex = RegExp(r'^(\d+)\s*x\s*(\d+)$');
    final match = regex.firstMatch(raw.trim());

    if (match != null) {
      final sets = match.group(1);
      final reps = match.group(2);
      return "$sets Sets x $reps Reps (Recommended)";
    }
    
    // If it doesn't match (e.g., implies it's already formatted or empty), return as is
    return raw; 
  }

  @override
  Widget build(BuildContext context) {
    final machineName = widget.machineData['name'];

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
          
          // --- CHANGED: Get raw string and apply formatting ---
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
                  GestureDetector(
                    onTap: () => _launchVideo(videoUrl),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(26)),
                        image: widget.machineData['icon'] != null 
                            ? DecorationImage(
                                image: NetworkImage(widget.machineData['icon']),
                                fit: BoxFit.cover,
                                opacity: 0.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, size: 30, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // Header Info
                Text(
                  machineName,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(difficulty,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.fitness_center,
                        color: kPrimaryColor, size: 18),
                    const SizedBox(width: 5),
                    
                    // --- CHANGED: Use the formatted string here ---
                    Flexible( // Added Flexible to prevent overflow if text is long
                      child: Text(formattedSetsReps,
                          style: const TextStyle(
                              color: kPrimaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Description
                const Text("DESCRIPTION",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1)),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      height: 1.6,
                      fontSize: 16),
                ),
                
                const SizedBox(height: 30),

                // Instructions
                if (instructionSteps.isNotEmpty) ...[
                  const Text("INSTRUCTIONS",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1)),
                  const SizedBox(height: 20),
                  
                  ...instructionSteps.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    String stepText = entry.value;
                    return _buildStep(index, stepText);
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: kCardColor, 
            child: Text(
              "$number",
              style: const TextStyle(
                  fontSize: 12,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    height: 1.4, color: Colors.white.withAlpha(230))),
          ),
        ],
      ),
    );
  }
}