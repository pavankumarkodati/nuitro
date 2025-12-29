import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/More/custom_back_button2.dart';
import 'package:nuitro/More/delete_account.dart';
import 'package:nuitro/More/help.dart';
import 'package:nuitro/More/privacy.dart';
import 'package:nuitro/More/terms_and_conditions.dart';
import 'package:nuitro/screens/auth/login_screen.dart';
import 'package:nuitro/services/secure_storage.dart';





class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget buildButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton2(label: 'More',),
        
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),child: Column(children: [
                buildButton("Terms and Conditions", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsAndConditions())
                  );})
              ,buildButton("Privacy Policy", () {Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Privacy())
                    );}),
                buildButton("Help", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Help())
                  );
                }),])),
        
              const SizedBox(height: 20),
              InkWell(
                onTap: (){
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Delete Account",
                    pageBuilder: (context, anim1, anim2) {
                      return DeleteAccountDialog(
                      );
                    },
                  );
        
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete Account',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 20),
              InkWell(
                onTap: (){
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Delete Account",
                    pageBuilder: (context, anim1, anim2) {
                      return LogOutDialog(
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Log Out',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class DeleteAccountDialog extends StatelessWidget {

  final  String name= "Jane Cooper";
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 27, backgroundColor: Colors.grey),
              Text(name,style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),),
              SizedBox(height: 15,),
              Text(
                "Are you sure you want \nto delete account?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Permanently remove your data and close your NutriAI account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[Container(width: 152,height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black, // Black container
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      border: Border.all(
                        color:  Color.fromRGBO(220, 250, 157, 1), // Green border
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () { Navigator.pop(context);
                        // Add your button action here
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:  Color.fromRGBO(220, 250, 157, 1), // Green text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                    Container(width: 152,height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(220, 250, 157, 1), // Green background
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () { Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  LogInPage(), // <-- replace with your login widget
                          ),
                              (route) => false,
                        );
                          // Add your button action here
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black, // White text
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                  ]),
            ],
          ),
        ),
      ),
    );
  }
}





















class LogOutDialog extends StatelessWidget {

  final  String name= "Jane Cooper";
  const LogOutDialog({super.key});

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(height: 15,),
              Text(
                "Are you sure you want \nto log out?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Log out will remove your access to personalized tracking and saved data until you log back in.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[Container(width: 152,height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black, // Black container
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      border: Border.all(
                        color:  Color.fromRGBO(220, 250, 157, 1), // Green border
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your button action here
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:  Color.fromRGBO(220, 250, 157, 1), // Green text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                    Container(width: 152,height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(220, 250, 157, 1), // Green background
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () async{
                          await TokenStorage.clearTokens();
                          Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  LogInPage(), // <-- replace with your login widget
                          ),
                              (route) => false,
                        );
                          // Add your button action here
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black, // White text
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Log Out",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                  ]),
            ],
          ),
        ),
      ),
    );
  }
}