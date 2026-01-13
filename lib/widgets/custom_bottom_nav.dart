import 'package:flutter/material.dart';
import '../core/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVerified;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.accessibility),
        label: 'Anterior',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.accessibility_new),
        label: 'Posterior',
      ),
    ];

    if (isVerified) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'Create',
        ),
      );
    }

    // Safety: ensure index doesn't crash if verified status changes
    int safeIndex = currentIndex;
    if (safeIndex >= items.length) {
      safeIndex = 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border(top: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: onTap,
        selectedItemColor: kPrimaryColor, // Ensure this constant exists
        unselectedItemColor: Colors.grey,
        backgroundColor: kBackgroundColor,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}