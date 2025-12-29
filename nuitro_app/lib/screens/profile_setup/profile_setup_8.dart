import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_1.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_9.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';

import 'package:nuitro/components/global_Constants.dart';
import 'package:nuitro/components/profile_submit_button.dart';
import 'package:nuitro/components/top_back_button.dart';

class Page8 extends StatefulWidget {
  const Page8({Key? key}) : super(key: key);

  @override
  _Page8State createState() => _Page8State();
}

class _Page8State extends State<Page8> {
  int _selectedPace = 0;
  final int currentPage = 8;

  final int totalPages = 8;

  final List<Map<String, String>> _paceOptions = [
    {'title': 'Relaxed', 'subtitle': 'No rush, I prefer steady progress'},
    {'title': 'Balanced', 'subtitle': 'I want to stay consistent but comfortable'},
    {'title': 'Focused', 'subtitle': 'I\'m ready to commit and stay on track'},
    {'title': 'Let AI decide for me', 'subtitle': 'I\'m open to what suits me best'},
  ];

  @override
  Widget build(BuildContext context) {
    double progress = currentPage / totalPages;
    return Scaffold(backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [SizedBox(height: 5,), CustomBackButton(),
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
                'What pace do you prefer for your progress?',
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),   textAlign: TextAlign.center,),
              const SizedBox(height: 8),
              Text(
                'Choose what suits your lifestyle - slow and steady or more focused.',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(117, 117, 117, 1)
                ),
                textAlign:TextAlign.center , ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _paceOptions.length,
                  itemBuilder: (context, index) {
                    final option = _paceOptions[index];
                    final isSelected = _selectedPace == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPace = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFDCFA9D) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(width: 1,color: Colors.grey)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.black : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['subtitle']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? Colors.black.withOpacity(0.7) : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ProfileSubmitButton(progress: progress, onNext: () { setState(()async {

                globalUserProfile.modeOfProgress=_paceOptions[_selectedPace]['title'];

                print("yoooooooooooooooooo");
                print(globalUserProfile.toJson());

                ApiResponse response= await ApiServices.updateUserProfile(globalUserProfile);

                if(response.status)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.message),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  Page9()),
                    );
                  }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: Colors.red,
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  Page9()),
                  );
                }


              });  },)
            ],
          ),
        ),
      ),
    );
  }
}
