import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/meal_diet/chat_bot.dart';
import 'package:nuitro/screens/meal_diet/diet_details.dart';
import 'package:nuitro/screens/meal_diet/nutrient_calculator.dart';

class DietPopupMenu extends StatelessWidget {
  const DietPopupMenu({super.key});

  void _showPopupMenu(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem(
          value: "get_plan",
          child: _buildMenuItem("Get Plan"),
        ),
        PopupMenuItem(
          value: "chatbot",
          child: _buildMenuItem("Nultro Chatbot"),
        ),
        PopupMenuItem(
          value: "grocery",
          child: _buildMenuItem("Generate Grocery List"),
        ),
        PopupMenuItem(
          value: "recipe",
          child: _buildMenuItem("Recipe Builder"),
        ),
      ],
      elevation: 8.0,
    );

    if (result != null) {
      switch (result) {
        case "get_plan":
        // TODO: Add Get Plan page navigation
          break;
        case "chatbot":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatBot()),
          );
          break;
        case "grocery":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NutrientCalculator()),
          );
          break;
        case "recipe":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NutrientCalculator()),
          );
          break;
      }
    }
  }

  static Widget _buildMenuItem(String text) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(fontSize: 14, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _showPopupMenu(context, details.globalPosition),
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}
