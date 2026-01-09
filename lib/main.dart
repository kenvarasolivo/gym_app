import 'package:flutter/material.dart';

void main() {
  runApp(const GymMachineApp());
}

// ------------------- THEME & CONSTANTS -------------------
const Color kPrimaryColor = Color(0xFFD0FD3E); // Lime Green
const Color kBackgroundColor = Color(0xFF1C1C1E); // Dark Grey
const Color kSurfaceColor = Colors.white;
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
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const BodyMapScreen(),
    );
  }
}

// ------------------- 1. BODY MAP SCREEN (Custom Asset) -------------------
class BodyMapScreen extends StatelessWidget {
  const BodyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Good Morning,", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text("User", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomBar(currentIndex: 1),
      body: Center(
        // CORRECTED: AspectRatio is a widget that wraps the content
        child: AspectRatio(
          aspectRatio: 1, // Adjust this number (Width / Height) to match your image
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              fit: StackFit.expand, 
              children: [
                // 1. YOUR CUSTOM IMAGE
                Image.asset(
                  'musclegroup.png',
                  fit: BoxFit.fill,
                ),

                // 2. RESPONSIVE BUTTONS (Using Alignment)
                // (0,0) is center. (-1,-1) is top-left. (1,1) is bottom-right.
                
                // CHEST (Red)
                const Align(
                  alignment: Alignment(0.0, -0.55),
                  child: MuscleTag(label: "Chest", isActive: true),
                ),

                // SHOULDERS (Green)
                const Align(
                  alignment: Alignment(-0.65, -0.65),
                  child: MuscleTag(label: "Shoulders", isActive: false),
                ),

                // ARMS (Blue)
                const Align(
                  alignment: Alignment(0.75, -0.2),
                  child: MuscleTag(label: "Arms", isActive: false),
                ),

                // ABS (Purple)
                const Align(
                  alignment: Alignment(0.0, -0.05),
                  child: MuscleTag(label: "Abs", isActive: false),
                ),

                // LEGS (Pink/Blue)
                const Align(
                  alignment: Alignment(0.4, 0.65),
                  child: MuscleTag(label: "Legs", isActive: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                  content: Text("$label workouts coming soon!"), 
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF1C1C1E),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.black : Colors.transparent, 
            width: 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(Icons.check_circle, size: 14, color: Colors.black),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.black87,
              ),
            ),
            if (!isActive) ...[
              const SizedBox(width: 5),
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
            ]
          ],
        ),
      ),
    );
  }
}

// ------------------- 2. MACHINE LIST SCREEN (CATEGORY) -------------------
class MachineListScreen extends StatelessWidget {
  const MachineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chest", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      bottomNavigationBar: const CommonBottomBar(currentIndex: 1),
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
              "Machine 1", 
              "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Machine 2", 
              "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Bench Press", 
              "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Cable Fly", 
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- 3. DETAIL SCREEN -------------------
class MachineDetailScreen extends StatelessWidget {
  const MachineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Machine 1", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: const CommonBottomBar(currentIndex: 1),
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
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2070&auto=format&fit=crop"),
                  fit: BoxFit.cover,
                  opacity: 0.6,
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("Beginner Friendly"),
                ),
                const SizedBox(width: 10),
                const Text("3 Sets x 12 Reps", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 25),

            // Description
            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "This machine specifically targets the pectoral muscles. It provides a safer alternative to the bench press for beginners.",
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 25),

            // Tutorial
            const Text("Tutorial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
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
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: kPrimaryColor,
            child: Text(
              "$number",
              style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

// ------------------- SHARED: BOTTOM BAR -------------------
class CommonBottomBar extends StatelessWidget {
  final int currentIndex;
  const CommonBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Matches "Search" in sketch
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined), // Matches the center shape in sketch2
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Matches "Profile" in sketch
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}