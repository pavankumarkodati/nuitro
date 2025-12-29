import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/progress_provider.dart';

class MacroEntries extends StatelessWidget {
  const MacroEntries({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors used for the three dot groups (match the screenshot)
    const Color colorA = Color(0xFFE25B7E); // pink/red
    const Color colorB = Color(0xFFF2A94F); // orange
    const Color colorC = Color(0xFF7B6BF0); // purple

    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        final entries = provider.macros.entries;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: entries.isEmpty
                    ? const Center(child: Text('No entries'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        physics: const BouncingScrollPhysics(),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _EntryRow(
                            date: entry.label,
                            a: (entry.values['carbs'] ?? 0).round(),
                            b: (entry.values['fat'] ?? 0).round(),
                            c: (entry.values['protein'] ?? 0).round(),
                            colorA: colorA,
                            colorB: colorB,
                            colorC: colorC,
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Single row: date on left, three dot+value groups on right
class _EntryRow extends StatelessWidget {
  final String date;
  final int a;
  final int b;
  final int c;
  final Color colorA;
  final Color colorB;
  final Color colorC;

  const _EntryRow({
    required this.date,
    required this.a,
    required this.b,
    required this.c,
    required this.colorA,
    required this.colorB,
    required this.colorC,
  });

  Widget _dotValue(Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF222222), fontSize: 14, fontWeight: FontWeight.w600),
            children: [
              TextSpan(text: '$value'),
              const TextSpan(
                text: ' g',
                style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layout: left date, right three groups aligned horizontally
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Date (left)
        Expanded(
          child: Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF222222),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // The three dot-value groups with flexible wrapping to avoid overflow
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 8,
            children: [
              _dotValue(colorA, a),
              _dotValue(colorB, b),
              _dotValue(colorC, c),
            ],
          ),
        ),
      ],
    );
  }
}