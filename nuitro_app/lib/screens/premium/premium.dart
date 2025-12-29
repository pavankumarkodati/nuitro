import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/premium/annual_plan.dart';
import 'package:nuitro/screens/premium/monthly_plan.dart';

import 'package:nuitro/More/custom_back_button2.dart';
class Premium extends StatelessWidget {
  const Premium({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              
            child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,children: [CustomBackButton2(label:'Premium' ,),
              
              
               SizedBox(height: 10,)
              ,   Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Take Nutrition to the Next Level",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Smarter tracking. Deeper insights. Real results.",
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: const Color.fromRGBO(220, 250, 157, 1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Monthly Plan
                    InkWell(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      onTap: () {
                        // Handle monthly plan click
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MonthlyPlan()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Monthly Plan",
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "\$4.99",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "/Month",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
              
                    Padding(padding:EdgeInsets.symmetric(horizontal: 25),child: Divider(height: 1, color: Colors.black.withOpacity(0.2))),
              
                    // Annual Plan
                    InkWell(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AnnualPlan()),
                        );
                        // Handle annual plan click
              
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Annual Plan",
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "\$29.99",
                                        style: GoogleFonts.manrope(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "/Year",
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),],
              
            ),
              
          ),
        )
    );
  }
}
