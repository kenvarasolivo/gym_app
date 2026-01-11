import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/muscle_tag.dart';

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
