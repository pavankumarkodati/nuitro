import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nuitro/components/top_back_button.dart';
import 'package:nuitro/screens/auth/email_verification.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/models/user.dart';
import 'package:nuitro/services/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nuitro/components/global_Constants.dart';
import 'package:nuitro/providers/auth_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String fullPhoneNumber = "";
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isSubmitted = false;

  final Color _accentGreen = const Color(0xFF91C788);
  final Color _buttonGreen = const Color(0xFFDCFA9D);
  final Color _subtitleGrey = const Color(0xFF757575);

  String generateOTP() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString(); // 6-digit OTP
  }

  TextStyle _labelStyle() {
    return GoogleFonts.manrope(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintText: hint,
      hintStyle: GoogleFonts.spaceGrotesk(
        color: const Color(0xFFC2C2C2),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentGreen, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentGreen, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!_isSubmitted) {
                          setState(() {
                            _isSubmitted = true;
                          });
                        }

                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please fill in all required fields.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        FocusScope.of(context).unfocus();
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final user = UserModel(
                            name: _fullNameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: fullPhoneNumber.isNotEmpty
                                ? fullPhoneNumber
                                : _phoneController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          final response =
                              await ApiServices.sendEmailOtp(user.email);

                          if (!mounted) return;

                          if (response.status) {
                            final backendOtp = response.data
                                    is Map<String, dynamic>
                                ? response.data["otp"]?.toString()
                                : null;

                            if (backendOtp == null || backendOtp.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Unable to get OTP. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                              ),
                            );
                            debugPrint('[DEV MODE] Email OTP: $backendOtp');

                            // Persist signup data without blocking transitions.
                            // Ignore result intentionally for faster navigation.
                            // ignore: unawaited_futures
                            Provider.of<UserProvider>(context, listen: false)
                                .setUser(user);

                            if (!mounted) return;
                            setState(() {
                              isLoading = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmailVerification(
                                  otp: backendOtp,
                                  email: user.email,
                                  phone: user.phone,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Signup failed: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Sign Up',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      color: const Color(0xFF434343),
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to log in page
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(),
                  Text(
                    'Create Your Nuitro Account',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Eat better. Get back on track.',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: _subtitleGrey,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text('Full Name', style: _labelStyle()),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fullNameController,
                    autovalidateMode: _isSubmitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF232220),
                    ),
                    decoration: _inputDecoration('Enter full name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Email', style: _labelStyle()),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: _isSubmitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF232220),
                    ),
                    decoration: _inputDecoration('Enter email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Mobile Number', style: _labelStyle()),
                  const SizedBox(height: 12),
                  IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: 'US',
                    autovalidateMode: _isSubmitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.onUserInteraction,
                    dropdownIconPosition: IconPosition.trailing,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF232220),
                    ),
                    decoration: _inputDecoration('Enter mobile number'),
                    onChanged: (phone) {
                      setState(() {
                        fullPhoneNumber = phone.completeNumber;
                      });
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Password', style: _labelStyle()),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    autovalidateMode: _isSubmitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF232220),
                    ),
                    decoration: _inputDecoration(
                      'Enter password',
                      suffix: IconButton(
                        splashRadius: 20,
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
