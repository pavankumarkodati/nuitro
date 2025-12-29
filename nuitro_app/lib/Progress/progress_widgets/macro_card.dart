import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/progress_provider.dart';

class MacroDistributionCard extends StatelessWidget {
  const MacroDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Consumer<ProgressProvider>(
        builder: (context, provider, _) {
          final summaries = provider.macros.summaries;

          Color colorFor(String label) {
            final l = label.toLowerCase();
            if (l.contains('carb')) return const Color(0xFF6EE7B7);
            if (l.contains('protein')) return const Color(0xFFF87171);
            if (l.contains('fat')) return const Color(0xFFD8B4FE);
            return Colors.grey.shade300;
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Macro Distribution",
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                Text(
                  summaries.isEmpty
                      ? "You're consistently low on protein."
                      : "Your macro split for the selected period.",
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: summaries.isEmpty ? 3 : summaries.length,
                    itemBuilder: (context, index) {
                      if (summaries.isEmpty) {
                        // Placeholder cards
                        const titles = ["Fats", "Carbs", "Protein"];
                        final colors = [
                          const Color(0xFFD8B4FE),
                          const Color(0xFF6EE7B7),
                          const Color(0xFFF87171),
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: const _MacroBox(
                            title: '—',
                            value: '--%',
                            color: Color(0xFFE5E7EB),
                          ),
                        );
                      }

                      final s = summaries[index];
                      final percent = s.percent.isNaN || s.percent.isInfinite
                          ? 0
                          : s.percent.round();
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _MacroBox(
                          title: s.label,
                          value: "$percent%",
                          color: colorFor(s.label),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MacroBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.symmetric(horizontal: 15,vertical:1 ),
      height: 88,
      width: 108,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
