import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nuitro/screens/auth/signup_screen.dart';

import 'onboarding_page_1.dart';
import 'onboarding_page_2.dart';
import 'onboarding_page_3.dart';

class OnboardingMain extends StatefulWidget {
  const OnboardingMain({super.key});

  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int totalPages = 3;

  void _goNextPage() {
    if (_currentPage < totalPages - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SignUp()),
            (route) => false,
      );
    }
  }

  void _goPreviousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD9F9),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          OnboardingScreen1(
            onNext: _goNextPage,
            onBack: _goPreviousPage,
            currentIndex: _currentPage,
            totalPages: totalPages,
          ),
          OnboardingScreen2(
            onNext: _goNextPage,
            onBack: _goPreviousPage,
            currentIndex: _currentPage,
            totalPages: totalPages,
          ),
          OnboardingScreen3(
            onNext: _goNextPage,
            onBack: _goPreviousPage,
            currentIndex: _currentPage,
            totalPages: totalPages,
          ),
        ],
      ),
    );
  }
}