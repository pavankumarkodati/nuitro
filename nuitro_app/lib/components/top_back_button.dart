import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Back Button0
          GestureDetector(
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),onTap: () {
            Navigator.pop(context); // 👈 go back to previous page
          },
          ),

          // Page Counter

        ],
      ),SizedBox(height: 15,)
    ]);
  }
}
