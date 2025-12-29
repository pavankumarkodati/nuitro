import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/auth/otp_verification_screen.dart';
import 'package:pinput/pinput.dart';

import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';

class EmailVerification extends StatefulWidget {
  final String otp;
  final String email;
  final String phone;

  const EmailVerification({super.key, required this.otp, required this.email, required this.phone});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  String _enteredOTP = "";

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(height: 90,padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
          child: Container(height:50 ,width: double.infinity,decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Color.fromRGBO(220, 250, 157, 1)),
            child: TextButton(onPressed : () async{
                // if (_enteredOTP == widget.otp) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text("OTP Verified!")),
                //   );
                //   // Navigate to next screen
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text("Invalid OTP!")),
                //   );
                // }
                ApiResponse response=await ApiServices.verifyEmailOtp(widget.email,_enteredOTP);
                if(response.status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MobileVerification(phone: widget.phone)),
                  );
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                    ),
                  );
                }

            }, child:Text('Verfiy',style: TextStyle(fontWeight: FontWeight.w500,fontSize:18,color: Colors.black ),) ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Verify Your Email Address",
                  style: GoogleFonts.manrope(fontSize:
              28,fontWeight: FontWeight.w500,color:
                  Colors.black)),
              SizedBox(height: 10),
              Text("Enter the code sent to ${widget.email}",style: GoogleFonts.manrope(fontSize: 15,
                  fontWeight: FontWeight.w400,color: Colors.grey),),
              SizedBox(height: 20),

              // Display OTP for demo
              // Text("OTP (for demo): ${widget.otp}", style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),

              Center(
                child: Pinput(
                  length: 6,
                  onChanged: (value) {
                    _enteredOTP = value;
                  },
                ),
              ),
              SizedBox(height: 30),



            ],
          ),
        ),
      ),
    );
  }
}
