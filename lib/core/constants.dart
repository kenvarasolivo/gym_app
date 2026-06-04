import 'package:flutter/material.dart';

// ------------------- THEME & CONSTANTS -------------------
const Color kPrimaryColor = Color(0xFFD0FD3E); // Lime Green
const Color kBackgroundColor = Color(0xFF121212); // Deep Dark Background
const Color kCardColor = Color(0xFF1C1C1E); // Slightly lighter for cards
const Color kSurfaceColor = Color(0xFF242426); // Elevated surface (inputs, chips)
const Color kMutedText = Color(0xFF8A8A8E); // Secondary/label text
const double kPadding = 20.0;

// Hairline border used on cards & surfaces for a crisp, premium edge.
final Color kBorderColor = Colors.white.withAlpha(20);

// Soft shadow used to lift cards off the background.
final List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Colors.black.withAlpha(90),
    blurRadius: 16,
    offset: const Offset(0, 8),
  ),
];

// Uppercase section label (e.g. "DESCRIPTION", "ACCOUNT INFO").
const TextStyle kSectionLabel = TextStyle(
  color: kMutedText,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
);