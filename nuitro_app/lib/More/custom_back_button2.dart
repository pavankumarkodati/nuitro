import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBackButton2 extends StatelessWidget {
  final String label;
  const CustomBackButton2({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // 👈 go back to previous page
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
