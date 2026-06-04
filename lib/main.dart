import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mfgzydsbbsmxybyxeytn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mZ3p5ZHNiYnNteHlieXhleXRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNTQ2MzksImV4cCI6MjA5NTYzMDYzOX0.nBaDZqEpr0QgWq_prz9bhSWlJuR8R6uUX7wDN_Htjx4',
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
      builder: (context, child) {
        // On the web demo, constrain the app to a phone-sized frame
        // and center it so it doesn't stretch across the whole browser.
        if (!kIsWeb) return child ?? const SizedBox.shrink();
        const phoneWidth = 412.0;
        final mq = MediaQuery.of(context);
        return ColoredBox(
          color: const Color(0xFF000000),
          child: Center(
            child: ClipRect(
              child: SizedBox(
                width: phoneWidth,
                child: MediaQuery(
                  // Report the constrained width so responsive widgets
                  // inside the app behave like they're on a phone.
                  data: mq.copyWith(size: Size(phoneWidth, mq.size.height)),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
