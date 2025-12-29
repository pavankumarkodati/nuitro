import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/Global/global_Constants.dart';
import 'package:nuitro/Profilesetup/page_5.dart';
import 'package:nuitro/Profilesetup/page_6.dart';
import 'package:nuitro/Profilesetup/page_8.dart';

import '../Global/profile_submit_button.dart';
import '../Global/top_back_button.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  int _selectedGoal = -1; // -1 = nothing selected
  int currentPage = 5;

  final int totalPages = 8;

  /// List of goals with title + asset image
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Gain weight',
      'image': 'assets/images/gain weight.png',
      'size':55.0
    },
    {
      'title': 'Gain Muscle',
      'image': 'assets/images/gainmuscle.png',
      'size':39.0
    },
    {
      'title': 'Lose Weight',
      'image': 'assets/images/looseweight.png',
      'size':34.0
    },
    {
      'title': 'Stay healthy',
      'image': 'assets/images/stayhealthy.png', 'size':40.0
    },
    {
      'title': 'Get Fitter',
      'image': 'assets/images/getfitter.png',
      'size':40.0
    },



  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5,),
              const CustomBackButton(),
              const SizedBox(height: 15),

              /// Page count
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: "$currentPage",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "/$totalPages",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Question
               Text(
                "What's your primary goal?",
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Whether it's fat loss, fitness, or muscle gain - we'll tailor your plan accordingly.",
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(117, 117, 117, 1)
                ), textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              /// List of goals
              Expanded(
                child: ListView.builder(
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGoalOption(
                        index,
                        goal['image']!,
                        goal['title']!,goal['size']!
                      ),
                    );
                  },
                ),
              ),

              /// Progress + next
              ProfileSubmitButton(
                progress: currentPage / totalPages,
                onNext: () {
                  if (_selectedGoal == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a goal before proceeding."),
                      ),
                    );
                    return;
                  }

                  globalUserProfile.primaryGoal=_goals[_selectedGoal]['title'].toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Page6()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(int index, String imagePath, String title,double size) {
    final isSelected = _selectedGoal == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = index;
        });
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(145, 199, 136, 0.27) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color.fromRGBO(145, 199, 136, 0.27) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              /// Asset image instead of icon


              Text(
                title,
                style:  TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
              Spacer(),

              Image.asset(
                imagePath,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
