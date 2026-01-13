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
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MachineListScreen(muscleGroup: label)),
              )
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
    
        width: 110, 
        
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : kCardColor, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? kPrimaryColor : Colors.grey, 
            width: 1.0
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            if (isActive) ...[
              const Icon(Icons.check_circle, size: 14, color: Colors.black),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isActive ? Colors.black : Colors.white, 
                  overflow: TextOverflow.ellipsis, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}