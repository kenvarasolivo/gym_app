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

  String? _selectedDifficulty;
  bool _sortAscending = true;

Future<void> _fetchMachines() async {
  setState(() => _loading = true);

  try {
    var query = supabase
        .from('machine_list')
        .select('id, name, icon, musclegroup, machine_detail!inner(difficulty)') // Join detail table
        .eq('musclegroup', widget.muscleGroup);

  
    final difficultyFilter = _selectedDifficulty;

    if (difficultyFilter != null) {
      query = query.eq('machine_detail.difficulty', difficultyFilter);
    }

    // Apply Sorting by Name
    final res = await query.order('name', ascending: _sortAscending);

    setState(() {
      _machines = res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _loading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _loading = false;
    });
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
        actions: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      onSelected: (value) {
        if (value == 'sort') {
          setState(() {
            _sortAscending = !_sortAscending; // Toggle order
          });
        } else {
          setState(() {
            // If same difficulty is pressed, clear filter; otherwise set it
            _selectedDifficulty = (_selectedDifficulty == value) ? null : value;
          });
        }
        _fetchMachines();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'sort',
          child: Row(
            children: [
              Icon(_sortAscending ? Icons.sort_by_alpha : Icons.text_rotate_vertical, color: Colors.black),
              const SizedBox(width: 8),
              Text(_sortAscending ? "Sort: Z-A" : "Sort: A-Z"),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(enabled: false, child: Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold))),
        _buildDifficultyItem("Beginner"),
        _buildDifficultyItem("Intermediate"),
        _buildDifficultyItem("Advanced"),
      ],
    ),
  ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : _error != null
              ? _buildMessage(Icons.error_outline, 'Something went wrong', _error!)
              : _machines.isEmpty
                  ? _buildMessage(
                      Icons.fitness_center,
                      'No machines yet',
                      'No ${widget.muscleGroup} workouts have been added.',
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                kPadding, 4, kPadding, 16),
                            child: Text(
                              '${_machines.length} ${_machines.length == 1 ? 'exercise' : 'exercises'}',
                              style: const TextStyle(color: kMutedText, fontSize: 13),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                              kPadding, 0, kPadding, kPadding),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildMachineCard(context, _machines[index]),
                              childCount: _machines.length,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildMessage(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kMutedText, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kMutedText, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String? _difficultyOf(Map<String, dynamic> machine) {
    final detail = machine['machine_detail'];
    if (detail is List && detail.isNotEmpty) {
      return (detail.first as Map)['difficulty']?.toString();
    }
    if (detail is Map) return detail['difficulty']?.toString();
    return null;
  }

  Widget _buildMachineCard(BuildContext context, Map<String, dynamic> machine) {
    // Extract the values from the map for display
    final name = machine['name'] ?? '';
    final imgUrl = machine['icon'] ?? '';
    final difficulty = _difficultyOf(machine);

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor),
        boxShadow: kCardShadow,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image fills the whole card
                if (imgUrl.isNotEmpty)
                  Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: kSurfaceColor,
                      child: const Icon(Icons.fitness_center,
                          color: kMutedText, size: 36),
                    ),
                  )
                else
                  Container(
                    color: kSurfaceColor,
                    child: const Icon(Icons.fitness_center,
                        color: kMutedText, size: 36),
                  ),

                // Dark gradient so the name stays readable over any image
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(30),
                        Colors.black.withAlpha(220),
                      ],
                      stops: const [0.4, 0.65, 1.0],
                    ),
                  ),
                ),

                // Difficulty badge (top-left)
                if (difficulty != null && difficulty.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _DifficultyBadge(level: difficulty),
                  ),

                // Name + play hint (bottom)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
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

  PopupMenuItem<String> _buildDifficultyItem(String level) {
  return PopupMenuItem(
    value: level,
    child: Row(
      children: [
        Icon(
          _selectedDifficulty == level ? Icons.check_box : Icons.check_box_outline_blank,
          color: kPrimaryColor,
        ),
        const SizedBox(width: 8),
        Text(level),
      ],
    ),
  );
}

}

// Small colour-coded pill showing an exercise's difficulty.
class _DifficultyBadge extends StatelessWidget {
  final String level;
  const _DifficultyBadge({required this.level});

  Color get _color {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF6BCB77);
      case 'intermediate':
        return const Color(0xFFFFC93C);
      case 'advanced':
        return const Color(0xFFFF6B6B);
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withAlpha(150)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            level,
            style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
