import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../More/custom_back_button2.dart';
class Notificationsss extends StatefulWidget {
  const Notificationsss({super.key});

  @override
  State<Notificationsss> createState() => _NotificationsssState();
}

class _NotificationsssState extends State<Notificationsss> {

  final List<String> notifications = [
    "It's time for your Lunch – Don’t forget to log your meal.",
    "You're doing great! Try adding more fiber-rich foods to hit today’s target.",
    "You've hit 80% of your daily calorie goal—keep it going!",
    "Congratulations on reaching your 100 days log streak! You earn it!",
    "It's time for your Lunch – Don’t forget to log your meal.",
    "Consider a light snack to help maintain your energy levels.",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
    body: SafeArea(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: SingleChildScrollView(
      child: Column(children: [
        CustomBackButton2(label: "Notification"),

        const SizedBox(height: 20),
        notifications.isEmpty? Column(
          children: [
            const SizedBox(height: 100),
            Container(
              width: 264,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Image(
                    image: AssetImage('assets/images/Sign In.png'),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'No notification Yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your healthy habits are on \ntrack—keep it up!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ):Container(height: 900,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/bellicon.png'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        notifications[index],
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),


      ],),
    ),)),);
  }
}
