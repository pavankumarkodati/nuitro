import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/premium/premium.dart';
import 'package:nuitro/screens/premium/review_summary.dart';
import 'package:nuitro/components/submit_button.dart';
import 'package:nuitro/More/custom_back_button2.dart';

class Payment extends StatefulWidget {
  final String selectedPlan;
  const Payment({super.key, required this.selectedPlan});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String selectedMethod = "Google Pay"; // <-- keeps track of selected payment method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: CustomElevatedButton(
          text: 'Continue',
          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReviewSummary (
                selectedPlan: widget.selectedPlan,   // from Premium
                paymentMethod: selectedMethod,       // from Payment
              )),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton2(label: 'Payment'),
              const SizedBox(height: 10),
            
              // Google Pay
              buildPaymentOption(
                title: "Google Pay",
                icon: Icon(Icons.apple),
                value: "Google Pay",
              ),
              const SizedBox(height: 12),
            
              // Apple Pay
              buildPaymentOption(
                title: "Apple Pay",
                icon: Icon(Icons.apple),
                value: "Apple Pay",
              ),
              const SizedBox(height: 12),
            
              // Visa
              buildPaymentOption(
                title: "Visa",
                icon: Icon(Icons.apple),
                value: "Visa",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentOption({
    required String title,
    required Widget icon,
    required String value,
  }) {
    bool isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value; // <-- update state
        });
      },
      child: Container(height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Color.fromRGBO(220, 250, 157, 1) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
