import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/onboarding/Navigation_buttons.dart';
import 'package:nuitro/screens/onboarding/page_indicator.dart';

import 'onboarding_page_2.dart';

class OnboardingScreen1 extends StatelessWidget {
  final VoidCallback onNext;
  final int currentIndex;
  final int totalPages;

  const OnboardingScreen1({
    super.key,
    required this.onNext,
    required this.currentIndex,
    required this.totalPages, required void Function() onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light pink background
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
                    const SizedBox(height:30),
        
                    Text(
                      'Your Day, Your Nutrition,\n At a Glance!',
                      textAlign: TextAlign.center,
                      style:  GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                        fontSize: 28,
                        color: Colors.black87,
                      ),
                    ),
        
                    const SizedBox(height: 10),
                    Text(
                      'Track your meals, monitor nutrients, and reach\nyour health goals with AI-powered support.',
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
                      child: Image.asset('assets/images/BGIonboarding1.png', height: 385,width: 389,),
                    ),
        
                    Spacer(),
                    NavigationButtons(isFirstPage:true,onNext: onNext),
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
