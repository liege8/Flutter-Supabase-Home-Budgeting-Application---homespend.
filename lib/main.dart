import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:araneta_HBA_it14/pages/onboarding_page.dart';
import 'package:araneta_HBA_it14/pages/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zwzjbhijoklnufqvdfjx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3empiaGlqb2tsbnVmcXZkZmp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5ODIxNTMsImV4cCI6MjA1NTU1ODE1M30.C1JSvmg9BLtlmK8wIPgv5dBD_HGaKVrPDVVxcAx-g_Q',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "homespend - ARANETA(IT14)",
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _position = 50;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _position = 0;
      });
    });

    // Navigate after 3 seconds
    Future.delayed(Duration(seconds: 3), () async {
      final session = Supabase.instance.client.auth.currentSession;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                session != null ? RootApp() : OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          duration: Duration(seconds: 2),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _position, 0), // Slide effect
          child: AnimatedOpacity(
            duration: Duration(seconds: 2),
            opacity: _opacity,
            child: Image.asset(
              "assets/images/splash2.jpg",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
