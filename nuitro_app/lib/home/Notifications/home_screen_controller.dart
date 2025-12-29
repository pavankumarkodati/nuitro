import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/screens/meal_diet/diets.dart';
import 'package:nuitro/settings/settings.dart';
import 'package:nuitro/screens/home/foodscan_screen.dart';
import 'package:nuitro/screens/home/home.dart';
import 'package:nuitro/home/homepage_widgets/buuomnavigation.dart';
import 'package:nuitro/Progress/progress_widgets/progress.dart';
import 'package:nuitro/providers/auth_provider.dart';

class HomeScreenController extends StatefulWidget {
  const HomeScreenController({super.key});

  @override
  State<HomeScreenController> createState() => _HomeScreenControllerState();
}

class _HomeScreenControllerState extends State<HomeScreenController> {
  int _selectedIndex = 0;

  List<Widget> _buildPages(String userName) {
    final effectiveName = userName.trim().isEmpty ? 'Guest' : userName;
    return [
      const HomeScreen(),
      const Progress(),
      const Diets(),
      Settings(
        userName: effectiveName,
        userImage: 'assets/images/MalePage1.png',
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<UserProvider>().ensureInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserProvider>().user?.name ?? '';
    final pages = _buildPages(userName);

    return  Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: SizedBox(
        width: 70, // make it as big as you want
        height: 70,
        child: FloatingActionButton(
          backgroundColor: const Color.fromRGBO(220, 250, 157, 1),
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FoodScanScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/Scan.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

  }
}
