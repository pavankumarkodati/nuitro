import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/home/home.dart';
import 'package:nuitro/settings/settings.dart';

import 'package:nuitro/screens/home/foodscan_screen.dart';
class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('assets/images/home.png', "Home", 0),
          _buildNavItem('assets/images/progress.png', "Progress", 1),
          const SizedBox(width: 40), // space for FAB
          _buildNavItem('assets/images/Meal.png', "Meal", 2),
          _buildNavItem('assets/images/settings.png', "Settings", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isSelected ? const Color.fromRGBO(220, 250, 157, 1) : Colors.white,
              BlendMode.srcIn,
            ),
            child: Image.asset(icon, width: 24, height: 24),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? const Color.fromRGBO(220, 250, 157, 1)
                  : Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
