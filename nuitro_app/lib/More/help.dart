import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/More/custom_back_button2.dart';
class Help extends StatelessWidget {

  const Help ({super.key});
  Widget buildBullet(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("• ", style: GoogleFonts.manrope(fontSize: 16)),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              
            child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,children: [
              CustomBackButton2(label:'Help' ,),
              
               Text(
                "Need Help?",
                style: GoogleFonts.manrope(fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                "We’re here to guide you every step of the way.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              
               Text(
                "Quick Help Topics",
                style: GoogleFonts.manrope( fontSize: 16),
              ),
              const SizedBox(height: 0),
              
              buildBullet("How to log a meal", "Step-by-step guide to track your food"),
              buildBullet("Setting your calorie goal", "Learn how Nultri calculates your targets"),
              buildBullet("Choosing a diet plan", "Understand what works best for your goals"),
              
              const SizedBox(height: 10),
               Text(
                "Contact Support",
                style: GoogleFonts.manrope( fontSize: 14),
              ),
              const SizedBox(height: 0),
               Text("Can’t find what you’re looking for?", style:GoogleFonts.manrope(fontSize: 14)),
              const SizedBox(height: 0),
               Text("[ Send Us a Message ]", style: GoogleFonts.manrope(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 0),
               Text("We usually respond within 24 hours.", style: GoogleFonts.manrope(fontSize: 14)),
              
              const SizedBox(height: 10),
               Text(
                "Helpful Links",
                style: GoogleFonts.manrope( fontSize: 14),
              ),
              const SizedBox(height: 6),
               Text("Privacy Policy", style: GoogleFonts.manrope(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 6),
               Text("Terms & Conditions", style: GoogleFonts.manrope(fontSize: 14, color: Colors.black)),
            ],
              
            ),
              
          ),
        )
    );

  }
}

