import 'package:flutter/material.dart';

void main() {
  runApp(const GymMachineApp());
}

// ------------------- THEME & CONSTANTS -------------------
const Color kPrimaryColor = Color(0xFFD0FD3E); // Lime Green
const Color kBackgroundColor = Color(0xFF121212); // Deep Dark Background
const Color kCardColor = Color(0xFF1C1C1E); // Slightly lighter for cards
const double kPadding = 20.0;

class GymMachineApp extends StatelessWidget {
  const GymMachineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Machine Guide',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor, 
          brightness: Brightness.dark
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const BodyMapScreen(),
    );
  }
}

// ------------------- 1. BODY MAP SCREEN (HOME) -------------------
class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  // 0 = Anterior (Front), 1 = Posterior (Back)
  int _currentViewIndex = 0; 

  @override
  Widget build(BuildContext context) {
    final bool isAnterior = _currentViewIndex == 0;

    return Scaffold(
      // Moved Profile and Search to AppBar because BottomBar is used for toggles
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.grey),
          onPressed: () {},
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
                fontWeight: FontWeight.w600
              )
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
              )
            ),
          ],
        ),
      ),
      
      // CUSTOM BOTTOM BAR FOR VIEW TOGGLING
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kBackgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentViewIndex,
          onTap: (index) {
            setState(() {
              _currentViewIndex = index;
            });
          },
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: kBackgroundColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility), 
              label: 'Anterior', 
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new), 
              label: 'Posterior', 
            ),
          ],
        ),
      ),

      body: Center(
        child: AspectRatio(
          aspectRatio: 1, 
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              fit: StackFit.expand, 
              children: [
                // 1. IMAGE SWITCHER
                Image.asset(
                  isAnterior ? 'frontmuscle.png' : 'backmuscle.png', 
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900], 
                      child: const Center(child: Text("Image Missing (Check Assets)", style: TextStyle(color: Colors.white)))
                    );
                  },
                ),

                // 2. MUSCLE TAGS (Switches based on state)
                if (isAnterior) ..._buildAnteriorTags() else ..._buildPosteriorTags(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- List of Buttons for Front View ---
  List<Widget> _buildAnteriorTags() {
    return const [
      //NOTES: Alignment(LEFT/RIGHT,UP/BOTTOM)
      Align(
        alignment: Alignment(-0.85, -0.68),
        child: MuscleTag(label: "Chest", isActive: true),
      ),
      Align(
        alignment: Alignment(-0.85, -0.46),
        child: MuscleTag(label: "Side Shoulders", isActive: false),
      ),
      Align(
        alignment: Alignment(-0.85, -0.27),
        child: MuscleTag(label: "Biceps", isActive: false),
      ),
      Align(
        alignment: Alignment(-0.85, -0.08),
        child: MuscleTag(label: "Arms", isActive: false),
      ),
      Align(
        alignment: Alignment(-0.85, 0.35),
        child: MuscleTag(label: "Quads", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, -0.70),
        child: MuscleTag(label: "Shoulders", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, -0.15), 
        child: MuscleTag(label: "Abs", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, 0.7),
        child: MuscleTag(label: "Legs", isActive: false),
      ),
    ];
  }

  // --- List of Buttons for Back View ---
  List<Widget> _buildPosteriorTags() {
    return const [
      //NOTES: Alignment(LEFT/RIGHT,UP/BOTTOM)
      Align(
        alignment: Alignment(-0.85, -0.68),
        child: MuscleTag(label: "Upper back", isActive: true),
      ),
      Align(
        alignment: Alignment(-0.85, -0.46),
        child: MuscleTag(label: "Rear Shoulders", isActive: false),
      ),
      Align(
        alignment: Alignment(-0.85, -0.27),
        child: MuscleTag(label: "Triceps", isActive: false),
      ),
      Align(
        alignment: Alignment(-0.85, -0.08),
        child: MuscleTag(label: "Lower Back", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, -0.70),
        child: MuscleTag(label: "Middle Back", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, -0.48),
        child: MuscleTag(label: "Lats", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, -0.15), 
        child: MuscleTag(label: "Glutes", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, 0.38),
        child: MuscleTag(label: "Hamstrings", isActive: false),
      ),
      Align(
        alignment: Alignment(0.85, 0.7),
        child: MuscleTag(label: "Calves", isActive: false),
      ),
    ];
  }
}

// ------------------- HELPER WIDGET -------------------
// ------------------- HELPER WIDGET -------------------
class MuscleTag extends StatelessWidget {
  final String label;
  final bool isActive;

  const MuscleTag({
    super.key, 
    required this.label, 
    required this.isActive
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MachineListScreen()))
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$label workouts coming soon!", style: const TextStyle(color: Colors.black)), 
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: kPrimaryColor, 
                ),
              );
            },
      child: Container(
        // 1. ADD FIXED WIDTH HERE
        width: 110, 
        
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : kCardColor.withOpacity(0.9), 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? kPrimaryColor : Colors.grey.withOpacity(0.3), 
            width: 1.0
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          // 2. CENTER THE CONTENT INSIDE THE FIXED WIDTH
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            if (isActive) ...[
              const Icon(Icons.check_circle, size: 14, color: Colors.black),
              const SizedBox(width: 6),
            ],
            // 3. WRAP TEXT IN FLEXIBLE TO PREVENT OVERFLOW ON SMALL BUTTONS
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isActive ? Colors.black : Colors.white, 
                  overflow: TextOverflow.ellipsis, // Adds "..." if text is too long
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- 2. MACHINE LIST SCREEN (RESTORED) -------------------
class MachineListScreen extends StatelessWidget {
  const MachineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHEST WORKOUT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,
          children: [
            _buildMachineCard(
              context, 
              "Chest Press", 
              "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Pec Fly", 
              "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Bench Press", 
              "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Cable Cross", 
              "https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?q=80&w=2069&auto=format&fit=crop"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineCard(BuildContext context, String name, String imgUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MachineDetailScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor, // Dark card
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity),
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
    );
  }
}

// ------------------- 3. DETAIL SCREEN (RESTORED) -------------------
class MachineDetailScreen extends StatelessWidget {
  const MachineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Placeholder
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2070&auto=format&fit=crop"),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, size: 30, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Header Info
            const Text(
              "Chest Press Machine",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Beginner Friendly", style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.fitness_center, color: kPrimaryColor, size: 18),
                const SizedBox(width: 5),
                const Text("3 Sets x 12 Reps", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),

            // Description
            const Text("DESCRIPTION", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 10),
            Text(
              "This machine specifically targets the pectoral muscles. It provides a safer alternative to the bench press for beginners.",
              style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Tutorial
            const Text("INSTRUCTIONS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 20),
            _buildStep(1, "Adjust the seat height so handles are at chest level."),
            _buildStep(2, "Grip the handles and push forward until arms are extended."),
            _buildStep(3, "Slowly return to start position."),
          ],
        ),
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
              style: const TextStyle(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: TextStyle(height: 1.4, color: Colors.white.withOpacity(0.9)))),
        ],
      ),
    );
  }
}