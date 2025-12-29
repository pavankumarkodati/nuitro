import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/auth/login_screen.dart';
import 'package:nuitro/screens/home/home.dart';
import 'package:nuitro/home/Notifications/home_screen_controller.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/services/services.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

import 'package:nuitro/screens/profile_setup/profile_splash_screen.dart';

class MobileVerification extends StatefulWidget {
  final String phone;

  const MobileVerification({super.key, required this.phone});

  @override
  State<MobileVerification> createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification> {
  String _enteredOTP = "";
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendMobileOtp();
    });
  }

  Future<void> _sendMobileOtp() async {
    if (!mounted) return;
    setState(() {
      _isResending = true;
    });
    try {
      final response = await ApiServices.sendMobileOtp(widget.phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.status ? null : Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _verifyAndSignup() async {
    if (_enteredOTP.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup details missing. Please restart signup.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final verifyResponse = await ApiServices.verifyMobileOtp(widget.phone, _enteredOTP);
      if (!verifyResponse.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResponse.message),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final signupResponse = await ApiServices.signup(
        user.email,
        user.name,
        user.phone,
        user.password,
      );

      if (signupResponse.status) {
        final data = signupResponse.data;
        final bool profileSetupDone =
            data is Map<String, dynamic> && (data['profile_setup_done'] == true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signupResponse.message)),
        );

        if (profileSetupDone) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenController()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen2()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(signupResponse.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to verify OTP: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(220, 250, 157, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _verifyAndSignup,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Verify',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.black),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 10),
              Text(
                "Verify Your Mobile Number",
                  style: GoogleFonts.manrope(fontSize:
                  28,fontWeight: FontWeight.w500,color: Colors.black) ),
              const SizedBox(height: 8),
              Text("Enter the code sent to ${widget.phone}",
                style: GoogleFonts.manrope(fontSize: 15,
                  fontWeight: FontWeight.w400,color: Colors.grey),),
              const SizedBox(height: 20),

              // Display OTP for demo
              const SizedBox(height: 20),

              // OTP Input
              Center(
                child: Pinput(
                  length: 6,
                  onChanged: (value) {
                    _enteredOTP = value;
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Resend Code (dummy)
              Center(
                child: Column(
                  children: [
                    const Text("Didn't receive code?"),
                    TextButton(
                      onPressed: (_isLoading || _isResending) ? null : _sendMobileOtp,
                      child: Text(
                        "Resend code",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (_isLoading || _isResending)
                              ? Colors.grey
                              : (isDarkMode
                                  ? const Color(0xFFD9FF9D)
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
