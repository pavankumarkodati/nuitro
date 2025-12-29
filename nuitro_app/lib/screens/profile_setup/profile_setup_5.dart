import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/profile_submit_button.dart';
import 'package:nuitro/components/top_back_button.dart';

import 'package:nuitro/screens/profile_setup/profile_setup_6.dart';

import 'package:nuitro/components/global_Constants.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  final Set<String> _selectedConditions = {};
  final int currentPage = 5;

  final int totalPages = 8;

  final List<String> _conditions = [
    'Obesity',
    'Diabetes',
    'Hypertension',
    'High Cholesterol',
    'Thyroid Disorders',
    'PCOS / PCOD',
    'Food Allergies',
    'None'
  ];

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentPage / totalPages;
    return Scaffold(backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [SizedBox(height: 5,),
              CustomBackButton(),
              const SizedBox(height: 15),
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
                'Do you have any medical conditions?',
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),   textAlign: TextAlign.center, ),
              const SizedBox(height: 8),
              Text(
                'This helps us track your progress and set realistic milestones.',
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(117, 117, 117, 1)
                  ),    textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _conditions.length,
                  itemBuilder: (context, index) {
                    final condition = _conditions[index];
                    final isSelected = _selectedConditions.contains(condition);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => _toggleCondition(condition),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey,width: 1)
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _conditions[index],
                                style: const TextStyle(fontSize: 16,color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ProfileSubmitButton(progress: progress, onNext: () { setState(() {

                globalUserProfile.medicalCondition= _selectedConditions.toList();
                // move to next page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Page7()),
                );
              });  },)
            ],
          ),
        ),
      ),
    );
  }
}
