import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package
import '../core/constants.dart';

class MachineDetailScreen extends StatefulWidget {
  // Pass the entire machine object (from the list screen) so we have the ID and Name immediately
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

  // Function to open the video link
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

  @override
  Widget build(BuildContext context) {
    // 1. Basic info is available immediately from the list (Name, ID)
    final machineName = widget.machineData['name'];

    return Scaffold(
      backgroundColor: kBackgroundColor, // Ensure you have this color constant
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
      // 2. Use FutureBuilder to load the extra details (Description, Video, etc.)
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          // Data from the database (can be null if not added yet)
          final detail = snapshot.data;
          
          final description = detail?['description'] ?? "No description available yet.";
          final instructionsText = detail?['instructions'] ?? "";
          final difficulty = detail?['difficulty'] ?? "General";
          final setsReps = detail?['sets_reps'] ?? "3 Sets x 12 Reps";
          final videoUrl = detail?['video'];

          // Split instructions by new line to make a list
          final List<String> instructionSteps = 
              instructionsText.toString().split('\n').where((s) => s.trim().isNotEmpty).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 3. DYNAMIC VIDEO PLAYER
                // Only show this container if videoUrl is not null and not empty
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
                        // You could use the icon from the previous screen as a thumbnail background
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
                      // Dynamic Difficulty
                      child: Text(difficulty,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.fitness_center,
                        color: kPrimaryColor, size: 18),
                    const SizedBox(width: 5),
                    // Dynamic Sets/Reps
                    Text(setsReps,
                        style: const TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.bold)),
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

                // Dynamic Instructions List
                if (instructionSteps.isNotEmpty) ...[
                  const Text("INSTRUCTIONS",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1)),
                  const SizedBox(height: 20),
                  
                  // Loop through the split text and build steps
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
            backgroundColor: kCardColor, // Make sure this matches your theme
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