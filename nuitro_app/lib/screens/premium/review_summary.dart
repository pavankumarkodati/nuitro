import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/premium/payment.dart';
import 'package:nuitro/components/submit_button.dart';
import 'package:nuitro/screens/home/home.dart';

import 'package:nuitro/More/custom_back_button2.dart';
class ReviewSummary extends StatelessWidget {
  final String selectedPlan;
  final String paymentMethod;

  const ReviewSummary({super.key, required this.selectedPlan, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: SafeArea(
      child: CustomElevatedButton(text: 'Continue', onPressed: (){
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Delete Account",
          pageBuilder: (context, anim1, anim2) {
            return CongratulationDialog();
          },
        );
      }),

    ),backgroundColor:Colors.white ,
      body:SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

          child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,children: [CustomBackButton2(label:'Review Summary' ,),


            SizedBox(height: 10,)
            ,
            Text("Your Plan", style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500)),
            Container(
              decoration: BoxDecoration(

                color: const Color.fromRGBO(220, 250, 157, 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Monthly Plan
                  InkWell(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                selectedPlan, // Just plan name
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: selectedPlan == "Monthly Plan" ? " \$4.99" : " \$29.99",
                                      //"\$4.99",
                                      style: GoogleFonts.manrope(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),

TextSpan(
  text: "/",
  style: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
                                  ],
                                ),
                              ),
                              Text(
                                 selectedPlan == "Monthly Plan" ? " Month" : " Year",
                                style:GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                        ],
                      ),
                    ),
                  ),

                 // Annual Plan

                ],
              ),
            ),
            SizedBox(height: 10,),
            Text("Payment Method:", style:GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 10,),
            Container(height: 80,

              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                 Icon( Icons.apple),
                  const SizedBox(width: 12),
                  Text(
                    paymentMethod,
                    style:GoogleFonts.manrope(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),

                ],
              ),
            ),




          ],

          ),

        ),
      ) ,

    );
  }
}











class CongratulationDialog extends StatelessWidget {


  const CongratulationDialog ({super.key});

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(height: 15,),
              Text(
                "Congratulation",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Congrats on upgrading to the Monthly Premium plan! Enjoy your new perks!" , textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Container(height: 50,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(220, 250, 157, 1), // Green background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () { Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  HomeScreen(), // <-- replace with your login widget
                    ),
                        (route) => false,
                  );
                    // Add your button action here
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Exploring Premium Plan",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}