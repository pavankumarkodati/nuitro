import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../More/custom_back_button2.dart';
class Notification1 extends StatefulWidget {
  const Notification1({super.key});

  @override
  State<Notification1> createState() => _Notification1State();
}

class _Notification1State extends State<Notification1> {
  bool mealReminders = true;
  bool progressSummary = true;
  bool goalMilestones = false;
  bool newPlanRecommendations = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
            CustomBackButton2(label:'Notifications',),
          // Profile Picture with edit button

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildSwitchRow("Meal Reminders", mealReminders, (value) {
                  setState(() {
                    mealReminders = value;
                  });
                }),
                buildSwitchRow("Progress Summary", progressSummary, (value) {
                  setState(() {
                    progressSummary = value;
                  });
                }),
                buildSwitchRow(
                    "Goal Milestone Notifications", goalMilestones, (value) {
                  setState(() {
                    goalMilestones = value;
                  });
                }),
                buildSwitchRow(
                    "New Plan Recommendations", newPlanRecommendations, (
                    value) {
                  setState(() {
                    newPlanRecommendations = value;
                  });
                }),
              ],
            ),
          )

          // Name


          ],
        ),
      ),
    ),);
  }
}













Widget buildSwitchRow(String title, bool value, Function(bool) onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical:3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.lightGreen,
          activeTrackColor: Colors.lightGreen[200],// The track color when ON
          inactiveThumbColor: Colors.blue,         // The thumb color when OFF
          inactiveTrackColor: Colors.grey[600],    // The track color when OFF
          thumbColor: MaterialStateProperty.all(Colors.white), // Force thumb color
          trackOutlineColor: MaterialStateProperty.all(Colors.transparent), // Outline
        ),
      ],
    ),
  );
}
