import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/onboarding/page_indicator.dart';

import 'Navigation_buttons.dart';
import 'onboarding_page_3.dart';

class OnboardingScreen2 extends StatelessWidget {
  final VoidCallback onNext;
  final int currentIndex;
  final int totalPages;
  final VoidCallback onBack;
  const OnboardingScreen2({
    super.key,
    required this.onNext,
    required this.currentIndex,
    required this.totalPages, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(226, 242, 255, 1), // Light pink background
      body: SafeArea(
        child: Stack(
          children: [
            // Optional decorative elements


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
                      'Track Everything That\n Matters',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                        fontSize: 28,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Snap,Scan,or Say It-Log in Seconds!',
                      textAlign: TextAlign.center,
                      style:  GoogleFonts.manrope(
                        fontSize: 13,
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
                      child: Image.asset('assets/images/BGIonboarding2.png', height: 410,width: 440.07),
                    ),

                    Spacer(),

                    NavigationButtons(onNext: onNext,onBack: onBack,),
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
