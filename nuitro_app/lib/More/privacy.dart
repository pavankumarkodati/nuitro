import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/More/custom_back_button2.dart';
class Privacy extends StatelessWidget {
  const Privacy ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              
            child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,children: [CustomBackButton2(label:'Terms & Privacy' ,),
              
              Text('Last Updated: 12 June,2025',style: GoogleFonts.manrope(fontWeight:FontWeight.w400,fontSize: 13 ),)
              , SizedBox(height: 10,)
              ,Text('Welcome to Nuitro your AI-powered nutrition assistant. Please read these Terms and Conditions carefully before using the Nutrio mobile application operated by us.',style: GoogleFonts.manrope(fontWeight:FontWeight.w400,fontSize: 13 ),)
            ],
              
            ),
              
          ),
        )
    );

  }
}
