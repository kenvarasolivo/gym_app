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
    final items = <_NavItem>[
      const _NavItem(Icons.accessibility_new_rounded, 'Anterior'),
      const _NavItem(Icons.accessibility_rounded, 'Posterior'),
      if (isVerified) const _NavItem(Icons.add_box_rounded, 'Create'),
    ];

    int safeIndex = currentIndex;
    if (safeIndex >= items.length) safeIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < items.length; i++)
                _NavButton(
                  item: items[i],
                  selected: i == safeIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 18 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? kPrimaryColor.withAlpha(28) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 22,
                color: selected ? kPrimaryColor : Colors.grey,
              ),
              // Only the active tab shows its label, keeping the bar clean.
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
