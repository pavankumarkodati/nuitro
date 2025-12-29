import 'package:flutter/material.dart';

class Frame61 extends StatelessWidget {
  const Frame61({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(color: Color(0xFFC93737)),
        ),
        const SizedBox(width: 5),
        const Text(
          'Stop',
          style: TextStyle(
            color: Color(0xFF434343),
            fontSize: 12,
            fontFamily: 'Zen Kaku Gothic Antique',
            fontWeight: FontWeight.w500,
            letterSpacing: -0.12,
          ),
        ),
      ],
    );
  }
}
