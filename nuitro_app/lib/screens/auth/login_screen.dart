import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/submit_button.dart';
import 'package:nuitro/screens/auth/email_verification.dart';
import 'package:nuitro/screens/auth/signup_screen.dart';
import 'package:nuitro/screens/profile_setup/profile_splash_screen.dart';
import 'package:nuitro/screens/home/home.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nuitro/home/Notifications/home_screen_controller.dart';
import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/screens/auth/forgot_password_screen.dart';


class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );
  // );
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromRGBO(220, 250, 157, 1)),
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            final response = await ApiServices.login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                            if (!mounted) return;

                            if (response.status) {
                              final payload = response.data;
                              if (payload is Map<String, dynamic>) {
                                final userMap = payload['user'];
                                if (userMap is Map<String, dynamic>) {
                                  await context
                                      .read<UserProvider>()
                                      .setUserFromMap(userMap);
                                } else {
                                  await context
                                      .read<UserProvider>()
                                      .loadUserFromStorage();
                                }
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response.message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreenController()),
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
                                content: Text('Login failed: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don’t have an account? ",
                    style:TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.black)
                          ,recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // 👇 Navigate to sign up page (replace with your route)
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
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text("Welcome Back to\nNuitro",
                      style: GoogleFonts.manrope(fontSize:
                      28,fontWeight: FontWeight.w500,color: Colors.black)),
                    Text(
                    "Eat better. Get back on track.",
                    style: GoogleFonts.manrope(fontSize: 15,
                        fontWeight: FontWeight.w400,color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction, // validate as user interacts
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                      hintStyle: GoogleFonts.spaceGrotesk(
                        color: Colors.grey,        //  sets the hint text color
                        fontSize: 17,              // optional: adjust size
                        fontWeight: FontWeight.w400,

                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 7,  //  Adjust this for vertical centering
                        horizontal: 12, // optional: for left/right spacing
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
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!_emailRegex.hasMatch(trimmed)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,

                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      hintStyle: GoogleFonts.spaceGrotesk(
                        color: Colors.grey,        // 👈 sets the hint text color
                        fontSize: 15,              // optional: adjust size
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 7,  //  Adjust this for vertical centering
                        horizontal: 12, // optional: for left/right spacing
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
                      final password = value ?? '';
                      if (password.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (password.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),



                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswoed ()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // OR Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey
                          ,
                          thickness: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        color: Colors.black,
                        child: Text(
                          "Or",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(height:50 ,width: double.infinity,decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Color.fromRGBO(47, 47, 47, 1)),
                    child: TextButton(onPressed : () {
                      // TODO: Implement Google Sign-In
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google Sign-In coming soon!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }, child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Image.asset('assets/images/google_logo.png', width: 24, height: 24,),SizedBox(width: 12,),Text('Continue with Google',style: TextStyle(fontWeight: FontWeight.w400,fontSize:15,color: Colors.white ),)]) ),
                  ),
                  const SizedBox(height: 18),
                  Container(height:50 ,width: double.infinity,decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Color.fromRGBO(47, 47, 47, 1)),
                    child: TextButton(onPressed : () {
                      // TODO: Implement Apple Sign-In
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Apple Sign-In coming soon!'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                    }, child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[FaIcon(FontAwesomeIcons.apple,color: Colors.white, size: 24,) ,SizedBox(width: 12,),Text('Continue with Apple',style: TextStyle(fontWeight: FontWeight.w400,fontSize:15,color: Colors.white ),)]) ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// icon: const FaIcon(
// FontAwesomeIcons.google,
// color: Colors.white,
// ),
// label: const Text("Continue with Google"),
// icon: const FaIcon(
// FontAwesomeIcons.apple,
// color: Colors.white,
// ),
// label: const Text("Continue with Apple"),
// ),