import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/onboarding/page_indicator.dart';
import 'package:nuitro/screens/auth/login_screen.dart';

import 'Navigation_buttons.dart';

class OnboardingScreen3 extends StatelessWidget {
  final VoidCallback onNext;
  final int currentIndex;
  final int totalPages;
  final VoidCallback onBack;
  const OnboardingScreen3({
    super.key,
    required this.onNext,
    required this.currentIndex,
    required this.totalPages, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

        
            Container(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Your Health Journey\n Starts Here',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                        fontSize: 28,
                        color: Colors.black87,
                      ),
                    ),
        
                    const SizedBox(height: 10),
                    Text(
                      'We help you choose healtheir foods and enjoy tasty,\nnutritious meals for your well-being.',
                      textAlign: TextAlign.center,
                      style:  GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(35, 34, 32, 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 80,
                      child: PageIndicator(
                        count: totalPages,
                        currentIndex: currentIndex,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/BGIonboarding3.png',height: 381,width: 438),
                    ),
        
                    Spacer(),
                    NavigationButtons(
                      onNext: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LogInPage()),
                        );
                      },onBack: onBack,
                    ),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
        
            // Next button
          ],
        ),
      ),
    );
  }
}
