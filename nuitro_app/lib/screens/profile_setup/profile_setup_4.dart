import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/global_Constants.dart';
import 'package:nuitro/components/profile_submit_button.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_5.dart';

import 'package:nuitro/components/multi_colour_button.dart';
import 'package:nuitro/components/top_back_button.dart';

class Page4 extends StatefulWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  bool _isCm = false;
  int _selectedCm = 170;
  int _selectedFeet = 5;
  int _selectedInches = 7;
   int currentPage = 4;

  final int totalPages = 8;

  late FixedExtentScrollController _cmController;
  late FixedExtentScrollController _feetController;
  late FixedExtentScrollController _inchesController;

  @override
  void initState() {
    super.initState();
    _cmController = FixedExtentScrollController(initialItem: _selectedCm - 100);
    _feetController = FixedExtentScrollController(initialItem: _selectedFeet - 3);
    _inchesController = FixedExtentScrollController(initialItem: _selectedInches);
  }

  @override
  void dispose() {
    _cmController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
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
              SizedBox(height: 5,),CustomBackButton(),
              SizedBox(height: 15,),
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

               Text(
                "How tall are you?",
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),    ),
              const SizedBox(height: 8),
              Text(
                'This helps us track your progress and set realistic milestones.',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(117, 117, 117, 1)
                ),  textAlign: TextAlign.center,),
              const SizedBox(height: 20),

              MultiColourButton(leftButton:'ft' , rightButton: 'cm', leftButtonTap: (){setState(() {
                _isCm=false;

              });}, rightButtonTap: (){
                setState(() {
                  _isCm=true;
                });
              }, isLeftSelected: _isCm),
              const SizedBox(height: 40),
              Expanded(
                child: _isCm ? _buildCmPicker() : _buildFtPicker(),
              ),
              ProfileSubmitButton(
                progress: currentPage / totalPages,
                onNext: () {
                  setState(() {

                    globalUserProfile.height= _selectedCm.toDouble();
                    // move to next page
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Page5()),
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



  Widget _buildCmPicker() {
    return Center(
      child: SizedBox(
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListWheelScrollView.useDelegate(
              controller: _cmController,
              itemExtent: 90,
              perspective: 0.005,
              diameterRatio: 8,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedCm = index + 100;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 151, // 100cm to 250cm
                builder: (context, index) {
                  final cm = index + 100;
                  final isSelected = _selectedCm == cm;
                  return Center(
                    child: Text(
                      cm.toString(),
                      style: TextStyle(
                        fontSize: isSelected ? 28 : 22,
                        color: isSelected ? Colors.black : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }

  Widget _buildFtPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListWheelScrollView.useDelegate(
                  controller: _feetController,
                  itemExtent: 90,
                  perspective: 0.005,
                  diameterRatio:8,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedFeet = index + 3;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 6, // 3ft to 8ft
                    builder: (context, index) {
                      final feet = index + 3;
                      final isSelected = _selectedFeet == feet;
                      return Center(
                        child: Text(
                          "$feet'",
                          style: TextStyle(
                            fontSize: isSelected ? 28 : 22,
                            color: isSelected ? Colors.black : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        Expanded(
          child: SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListWheelScrollView.useDelegate(
                  controller: _inchesController,
                  itemExtent: 90,
                  perspective: 0.005,
                  diameterRatio: 8,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedInches = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 12, // 0 to 11 inches
                    builder: (context, index) {
                      final inches = index;
                      final isSelected = _selectedInches == inches;
                      return Center(
                        child: Text(
                          '\"$inches\"',
                          style: TextStyle(
                            fontSize: isSelected ? 28 : 22,
                            color: isSelected ? Colors.black : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      ],
    );
  }
}
