import'package:flutter/material.dart';
import '../core/constants.dart';


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
                border: Border.all(color: Colors.white.withAlpha(26)),
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
                    color: Colors.white.withAlpha(26),
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
              style: TextStyle(color: Colors.white.withAlpha(204), height: 1.6, fontSize: 16),
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
          Expanded(child: Text(text, style: TextStyle(height: 1.4, color: Colors.white.withAlpha(230)))),
        ],
      ),
    );
  }
}
