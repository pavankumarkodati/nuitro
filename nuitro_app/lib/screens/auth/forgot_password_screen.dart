import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/auth/login_screen.dart';
import 'package:nuitro/screens/auth/reset_password_screen.dart';

import 'package:nuitro/components/submit_button.dart';
import 'email_verification.dart';

class ForgotPasswoed extends StatefulWidget {
  const ForgotPasswoed({super.key});

  @override
  State<ForgotPasswoed> createState() => _ForgotPasswoedState();
}

class _ForgotPasswoedState extends State<ForgotPasswoed> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? const Color(0xFFD9FF9D) : Colors.black;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(height:50 ,width: double.infinity,decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Color.fromRGBO(220, 250, 157, 1)),
                child: TextButton(onPressed : () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPassword()),
                    );
                  }
                }, child:Text('Send Reset Link',style: TextStyle(fontWeight: FontWeight.w500,fontSize:15,color: Colors.black ),) ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogInPage()),
                  );
                },
                child: Text('Back to Login', style: TextStyle(color: textColor)),
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
                    "Forgot Your Password?",
                      style: GoogleFonts.manrope(fontSize:
                      28,fontWeight: FontWeight.w500,color:
                      Colors.black)),
                  const SizedBox(height: 8),
                   Text(
                    "No worries! Enter your email,and we will\nSend you a reset link ",
                    style: GoogleFonts.manrope(fontSize: 15,
                        fontWeight: FontWeight.w400,color: Colors.grey), ),
              
                  const SizedBox(height: 40),
              
                  // OTP Input
                  const Text(
                    "Email",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    height: 80, // increased height so error message fits
                    child: TextFormField(
                      controller: _emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction, // validate as user interacts
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        hintStyle: GoogleFonts.spaceGrotesk(
                          color: Colors.grey,        // 👈 sets the hint text color
                          fontSize: 15,              // optional: adjust size
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
              
                  const SizedBox(height: 30),
              
                  // Resend Code
                
              
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
