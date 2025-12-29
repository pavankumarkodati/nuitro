import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/global_Constants.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_3.dart';

import 'package:nuitro/components/profile_submit_button.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  int currentPage = 2;

  final int totalPages = 8;

  int _selectedAge = 21;
  late FixedExtentScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: _selectedAge - 10);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentPage / totalPages;

    return Scaffold(backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5,),
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
                "What's your Age \n(in years)?",
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),textAlign:TextAlign.center ,
              ),
              const SizedBox(height: 8),
              Text(
                'We need this to personalize your nutrition, fitness, and health goals based on your age.',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(117, 117, 117, 1)
                ), textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 90,
                        perspective: 0.005,
                        diameterRatio: 8,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedAge = index + 10;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 90,
                          builder: (context, index) {
                            final age = index + 10;
                            final isSelected = _selectedAge == age;
                            final double opacity = isSelected ? 1.0 : 0.8;

                            return Center(
                              child: Opacity(
                                opacity: opacity,
                                child: Text(
                                  age.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 22,
                                    color: Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),


                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.black, width: 2),
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),

              // Bottom Progress Button
              ProfileSubmitButton(
                progress: currentPage / totalPages,
                onNext: () {
                  setState(() {

                    globalUserProfile.age=_selectedAge;
                    // move to next page
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Page3()),
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
}
