import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../screens/machine_detail_screen.dart';
import '../supabase/post_functions.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/youtube_player_widget.dart';

class MachineListScreen extends StatefulWidget {
  final String muscleGroup;

  const MachineListScreen({super.key, required this.muscleGroup});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _machines = [];

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await supabase
          .from('machine_list')
          .select('id, name, icon, musclegroup')
          .eq('musclegroup', widget.muscleGroup);

      _machines = res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.muscleGroup.toUpperCase()} WORKOUT",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.white.withAlpha(200))))
                : _machines.isEmpty
                    ? Center(child: Text('No machines found for ${widget.muscleGroup}', style: TextStyle(color: Colors.white.withAlpha(200))))
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                        children: _machines.map((m) => _buildMachineCard(context, m)).toList(),
                      ),
      ),
    );
  }

  Widget _buildMachineCard(BuildContext context, Map<String, dynamic> machine) {
    // Extract the values from the map for display
    final name = machine['name'] ?? '';
    final imgUrl = machine['icon'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (imgUrl.isNotEmpty && _isYouTubeUrl(imgUrl)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(),
                    body: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: YouTubeVideoPlayer(videoUrl: imgUrl),
                    ),
                  ),
                ),
              );
              return;
            }

            if (imgUrl.isNotEmpty && _isVideoUrl(imgUrl)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(),
                    body: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: VideoPlayerWidget(videoUrl: imgUrl),
                    ),
                  ),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (_) => MachineDetailScreen(machineData: machine),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imgUrl.isNotEmpty
                      ? Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity)
                      : Container(color: Colors.black12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isYouTubeUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') || lower.contains('youtu.be') || lower.contains('/shorts/');
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm') || lower.endsWith('.mkv');
  }

}
