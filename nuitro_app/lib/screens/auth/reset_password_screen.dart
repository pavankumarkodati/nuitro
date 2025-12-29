import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/auth/login_screen.dart';
import 'package:nuitro/screens/auth/signup_screen.dart';

import 'package:nuitro/components/submit_button.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    final textColor =  Colors.black;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
         height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
          child: Column(
            children: [
              Container(height:50 ,width: double.infinity,decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Color.fromRGBO(220, 250, 157, 1)),
                child: TextButton(onPressed : () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordChangedDialog(onLoginPressed: () {  Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LogInPage()),
                      ); },)),
                    );
                  }
                }, child:Text('Reset Password',style: TextStyle(fontWeight: FontWeight.w500,fontSize:15,color: Colors.black ),) ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomBackButton(),
                   Text(
                    "Reset Your Password?",
                      style: GoogleFonts.manrope(fontSize:
                      28,fontWeight: FontWeight.w500,color:
                      Colors.black) ),
                  const SizedBox(height: 8),
                   Text(
                    "Enter a new password to regain access\n to your account",
                    style: GoogleFonts.manrope(fontSize: 15,
                        fontWeight: FontWeight.w400,color: Colors.grey),
                  ),
                  const Text(
                    "to your account",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 40),

                  // OTP Input
                  const Text(
                    "New Password",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 80, // increased height so error message fits
                    child: TextFormField(
                      controller: _newPasswordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction, // validate as user interacts
                      decoration: InputDecoration(
                        hintText: "Enter New password",
                        hintStyle: GoogleFonts.spaceGrotesk(
                          color: Colors.grey,        // 👈 sets the hint text color
                          fontSize: 15,              // optional: adjust size
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your emai l';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Confirm Password",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 80,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: "Enter Confirm Password",
                        hintStyle: GoogleFonts.spaceGrotesk(
                          color: Colors.grey,        // 👈 sets the hint text color
                          fontSize: 15,              // optional: adjust size
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Verify Button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordChangedDialog extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const PasswordChangedDialog({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Password changed",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your password has been updated! You can now log in with your new credentials.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Log In',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
