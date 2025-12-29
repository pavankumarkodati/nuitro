import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/settings/settings.dart';

import 'package:nuitro/More/custom_back_button2.dart';
import 'package:nuitro/components/submit_button.dart';

class ChangePassword extends StatefulWidget {

  const ChangePassword({
    Key? key,

  }) : super(key: key);

  @override
  State<ChangePassword> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ChangePassword> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children:[Text(label,style: GoogleFonts.spaceGrotesk(fontSize:17 ,fontWeight: FontWeight.w400),),
          SizedBox(height: 4,),
          TextField(
            controller: controller,

            decoration: InputDecoration(
              hintText: label,hintStyle: GoogleFonts.spaceGrotesk(fontSize:17 ,fontWeight: FontWeight.w400,color: Colors.grey),

              border: OutlineInputBorder(borderRadius:BorderRadius.circular(18)),
            ),
          ),
        ] );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
      SafeArea(child: CustomElevatedButton(text: 'Save', onPressed: (){
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Delete Account",
          pageBuilder: (context, anim1, anim2) {
            return PasswordchangedDialog();
          },
        );
      })),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomBackButton2(label:'Change Password' ,),
              // Profile Picture with edit button

              const SizedBox(height: 24),

              // Name
              buildTextField("New Password", nameController),
              const SizedBox(height: 16),

              // Email
              buildTextField("Confirm Password", emailController),
              const SizedBox(height: 16),

              // DOB + Gender




            ],
          ),
        ),
      ),
    );
  }
}





















class PasswordchangedDialog extends StatelessWidget {


  const  PasswordchangedDialog ({super.key});

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
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(height: 15,),
              Text(
                "Password changed",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Congratulation! Your password has been updated!" , textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Container(height: 50,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(220, 250, 157, 1), // Green background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () { Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  Settings(userName: 'Andrew', userImage: ''), // <-- replace with your login widget
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
                    "Go Back",
                    style: TextStyle(fontSize: 18),
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