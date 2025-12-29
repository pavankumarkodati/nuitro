import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Submit extends StatelessWidget {
  final String text;             // button text
  final VoidCallback onPressed;  // action when pressed

  const Submit({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromRGBO(220, 250, 157, 1),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: GoogleFonts.manrope(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
