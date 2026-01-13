import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nohtbajprkcfgdtjshfc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vaHRiYWpwcmtjZmdkdGpzaGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxNTMxMTIsImV4cCI6MjA4MzcyOTExMn0.kAbk9eiAvVBn6b28jl6qfg1_DWIeIgI_rjsF1kuPTio',
  );

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
      home: const LoginScreen(),
    );
  }
}
