import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';
import 'package:nuitro/home/Notifications/home_screen_controller.dart';

class Page9 extends StatefulWidget {
  const Page9({Key? key}) : super(key: key);

  @override
  State<Page9> createState() => _Page9State();
}

class _Page9State extends State<Page9> {
  @override
  void initState() {
    super.initState();
    // Wait for 4 seconds then navigate
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenController()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Center(
            child: Container(
              height: 470,
              width: 264,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Image(
                    image: AssetImage('assets/images/Sign In.png'),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Preparing your plan...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'Setting up your nutrition plan and analyzing your goals...',
                    textAlign: TextAlign.center,
                    style:GoogleFonts.manrope (fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
