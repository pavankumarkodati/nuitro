import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/premium/payment.dart';
import 'package:nuitro/screens/premium/premium.dart';
import 'package:nuitro/components/submit_button.dart';
import 'package:nuitro/More/custom_back_button2.dart';

class AnnualPlan extends StatelessWidget {
  const AnnualPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomElevatedButton(
        text: 'Continue with \$29.99',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Payment(selectedPlan: "Annual Plan")),
          );
        },
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton2(label: 'Annual Plan'),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/premium2.png'),
                    SizedBox(height: 30),
                    Text(
                      "Upgrade to Premium",
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    FeatureList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureList extends StatelessWidget {
  const FeatureList({super.key});

  final List<String> features = const [
    "AI-Powered Meal Suggestions",
    "Advanced Nutrient Breakdown",
    "Access to All Premium Diets",
    "Unlimited Saved Foods & Meals",
    "Weekly AI Progress Reports",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black, // Background color
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check_circle,
                  color: Colors.grey,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}