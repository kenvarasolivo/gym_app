import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/body_map_screen.dart';

void main() {
  runApp(const GymMachineApp());
}


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
