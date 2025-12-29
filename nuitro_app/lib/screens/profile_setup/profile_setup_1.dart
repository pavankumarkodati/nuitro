import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/global_Constants.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_2.dart';

import 'package:nuitro/components/profile_submit_button.dart';

class Page1 extends StatefulWidget {
  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  int currentPage = 1;

  final int totalPages = 8;
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    double progress = currentPage / totalPages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5,),
              // Top Row
              CustomBackButton(),
              SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: "$currentPage",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "/$totalPages",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // Title0
              Text(
                "How do you Identify\nYourself?",
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
              ),
              SizedBox(height: 10),

              // Subtitle
              Text(
                "We will use this data to give you\na better diet type for you",
                textAlign: TextAlign.center,style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(117, 117, 117, 1)
              ),
              ),
              SizedBox(height: 40),

              // Options
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(

                      label: "Male",
                      isSelected: selectedGender == 'Male', onTap: () {
                      setState(() {
                        selectedGender = "Male";
                      });
                    }, imagePath: 'assets/images/MalePage1.png',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildOptionCard(

                      label: "Female",
                      isSelected: selectedGender == 'Female', onTap: () {
                      setState(() {
                        selectedGender = "Female";
                      });
                    }, imagePath: 'assets/images/FemalePage1.png',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Rather Not Say
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                    side: BorderSide(color: Colors.black54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          7), // adjust radius here
                    ),
                  ),
                  onPressed: () {
                  },
                  child: Text(
                    "I rather not Say", style: TextStyle(color: Colors.black),),
                ),
              ),
              Spacer(),

              // Bottom Progress Button
              ProfileSubmitButton(
                progress: currentPage / totalPages,
                onNext: () {
                  setState(() {
                    globalUserProfile.gender=selectedGender;
                    // move to next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Page2()),
                    );
                  });
                },
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String imagePath, // asset image instead of IconData
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: 157,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.fromRGBO(7, 40, 70, 0.17)
              : Color.fromRGBO(246, 247, 247, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80, // same as icon size
              height: 80, // keeps it square
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}