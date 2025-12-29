import 'package:flutter/material.dart';
import 'package:nuitro/screens/onboarding/onboarding_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!_navigated) {
        _navigateToOnboarding();
      }
    });
  }

  void _navigateToOnboarding() {
    setState(() {
      _navigated = true;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingMain()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFDCFA9D), // Single solid color instead of gradient
        ),
        child: const Center(
          child: Image(
            image: AssetImage('assets/images/Nuitro_logo.png'),
            width: 220, // Approx per Figma dimensions
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
