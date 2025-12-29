import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/profile_submit_button.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_8.dart';

import 'package:nuitro/components/global_Constants.dart';


class Page7 extends StatefulWidget {
  const Page7({super.key});

  @override
  _Page7State createState() => _Page7State();
}

class _Page7State extends State<Page7> {
  final Set<String> _selectedPreference = {};
  final int currentPage = 7;

  final int totalPages = 8;


  final List<String> _preference = [
    'Vegan',
    'Eggtarian',
    'Low Carb',
    'PCOS/PCOD-Friendly',
    'Gluten-Free',
    'Diary-Free',
    'Keto',
  ];

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreference.contains(preference)) {
        _selectedPreference.remove(preference);
      } else {
        _selectedPreference.add(preference);
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
            children: [
              SizedBox(height: 5,),
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
                  ]
                ),
              ),
               Text(
                'Do you have any medical conditions?',
                 style: GoogleFonts.manrope(
                     fontSize: 28,
                     fontWeight: FontWeight.w500,
                     color: Colors.black
                 ),  textAlign: TextAlign.center, ),
              const SizedBox(height: 8),
              Text(
                  'This helps us track your progress and set realistic milestones.',
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(117, 117, 117, 1)
                  ), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _preference.length,
                  itemBuilder: (context, index) {
                    final preference = _preference[index];
                    final isSelected = _selectedPreference.contains(preference);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => _togglePreference(preference),
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
                                _preference[index],
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

                globalUserProfile.foodPreference = _selectedPreference.toList();
                // move to next page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page8()),
                );
              });  },)
            ],
          ),
        ),
      ),
    );
  }
}
