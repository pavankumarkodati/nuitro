import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/progress_provider.dart';

class Entries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Consumer<ProgressProvider>(
        builder: (context, provider, _) {
          final items = provider.calories.entries;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Entries",
                style: GoogleFonts.manrope(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 139,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: items.isEmpty
                    ? const Center(child: Text("No entries found"))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final e = items[index];
                          final dateLabel = e.date != null
                              ? (e.date!.toIso8601String().split('T').first)
                              : e.label;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateLabel,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "${e.value.toStringAsFixed(0)} kcal",
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
