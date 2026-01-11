import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../screens/machine_list_screen.dart';

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