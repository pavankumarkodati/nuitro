import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/onboarding/onboarding_main.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_1.dart';
import 'package:provider/provider.dart';
import 'package:nuitro/providers/auth_provider.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
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
      MaterialPageRoute(builder: (context) =>  Page1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/Splashscreen2.png',
              width: double.maxFinite,
              fit: BoxFit.cover,
            ),
          ),
          Opacity(opacity:0.3,child: Container(color:Color.fromRGBO(220, 250, 157, 1) ,)),
          Center(
            child:  Text(
              'Welcome ${user?.name ?? 'Guest'}\n Let Setup your Account',
              softWrap: true,
              style: GoogleFonts.manrope(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
