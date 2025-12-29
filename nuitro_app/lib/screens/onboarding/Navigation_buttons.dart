import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool isLastPage;
  final bool isFirstPage;

  const NavigationButtons({
    Key? key,
    this.onNext,
    this.onBack,
    this.isLastPage = false,
    this.isFirstPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          // Back button (hide if first page)
          if (!isFirstPage)
            GestureDetector(
              onTap: onBack,
              child: Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          if (!isFirstPage) const SizedBox(width: 10),

          // Next / Get Started button
          Expanded(
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                height: 58,width: 245,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAFCB7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                     'Next',
                      style:  GoogleFonts.manrope(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                       Icons.arrow_forward,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
