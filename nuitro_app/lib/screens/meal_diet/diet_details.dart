import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/diet_provider.dart';
import 'package:nuitro/screens/meal_diet/diet_summery_card.dart';
import 'package:nuitro/screens/meal_diet/pop_up_menu.dart';
import 'package:nuitro/services/services.dart';

class DietDetails extends StatefulWidget {
  const DietDetails({
    super.key,
    required this.name,
    required this.imagePath,
    required this.goal,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.waterLiters,
    this.intakeText,
    this.existingDietId,
  });

  final String name;
  final String imagePath;
  final String goal;
  final String description;
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fat; // grams
  final int fiber; // grams
  final double waterLiters; // liters
  final String? intakeText; // e.g., "2000 kcal (1800–2200)"
  final String? existingDietId;

  @override
  State<DietDetails> createState() => _DietDetailsState();
}

class _DietDetailsState extends State<DietDetails> {
  bool _saving = false;
  bool _alreadyAdded = false;
  // Compute macro percentages based on kcal contributions
  ({double p, double c, double f}) _macroPercents() {
    final pCal = widget.protein * 4.0;
    final cCal = widget.carbs * 4.0;
    final fCal = widget.fat * 9.0;
    final total = pCal + cCal + fCal;
    if (total <= 0) {
      return (p: 0.0, c: 0.0, f: 0.0);
    }
    return (p: pCal / total, c: cCal / total, f: fCal / total);
  }

  double? get _calorieGoal {
    final raw = widget.intakeText;
    if (raw == null) return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*kcal', caseSensitive: false)
        .firstMatch(raw);
    if (match == null) return null;
    return double.tryParse(match.group(1) ?? '');
  }

  @override
  void initState() {
    super.initState();
    _alreadyAdded = (widget.existingDietId?.isNotEmpty ?? false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSavedState());
  }

  void _ensureSavedState() {
    if (!mounted || _alreadyAdded) return;
    try {
      final provider = context.read<DietProvider>();
      final normalizedName = widget.name.toLowerCase().trim();
      final normalizedDescription = widget.description.trim();
      final exists = provider.myDiets.any((plan) {
        final sameId = plan.id.isNotEmpty &&
            (widget.existingDietId?.isNotEmpty == true) &&
            plan.id == widget.existingDietId;
        final sameContent = plan.name.toLowerCase().trim() == normalizedName &&
            plan.description.trim() == normalizedDescription;
        return sameId || sameContent;
      });
      if (exists) {
        setState(() => _alreadyAdded = true);
      }
    } catch (_) {
      // DietProvider not available in the widget tree; ignore.
    }
  }

  Widget _buildHeroImage() {
    const fallbackPath = 'assets/images/Food.png';
    final source = widget.imagePath.trim();

    if (source.isEmpty) {
      return Image.asset(
        fallbackPath,
        fit: BoxFit.cover,
      );
    }

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          fallbackPath,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        fallbackPath,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Top banner image
            SizedBox(
              height: 271,
              width: double.infinity,
              child: _buildHeroImage(),
            ),

            // Top row with back + menu buttons


            // Content scroll
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 230),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(widget.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            )),
                        const SizedBox(height: 5),

                        // Description
                        Text(widget.description,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                            softWrap: true),
                        const SizedBox(height: 10),

                        // Diet summary card
                        Builder(builder: (context) {
                          final perc = _macroPercents();
                          return DietSummaryCard(
                            calories: widget.calories,
                            calorieGoal: _calorieGoal,
                            proteinPercent: perc.p,
                            carbsPercent: perc.c,
                            fatPercent: perc.f,
                          );
                        }),

                        const SizedBox(height: 10),

                        // Intake text / extras
                        if (widget.intakeText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(widget.intakeText!,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                )),
                          ),

                        // Fiber & Water quick facts
                        Row(
                          children: [
                            Text('Fiber: ${widget.fiber} g',
                                style: GoogleFonts.manrope(fontSize: 14)),
                            const SizedBox(width: 12),
                            Text('Water: ${widget.waterLiters.toStringAsFixed(1)} L',
                                style: GoogleFonts.manrope(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Goal section
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: const Color.fromRGBO(226, 242, 255, 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                    'assets/images/Goal Icon.png'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Goal',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Text(widget.goal,
                                        softWrap: true,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add to My Diet button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          child: _alreadyAdded
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(198, 254, 202, 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.check_circle, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(
                                        'Diet already in My Diets',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(220, 250, 157, 1),
                                  ),
                                  child: TextButton(
                                    onPressed: _saving
                                        ? null
                                        : () async {
                                            setState(() {
                                              _saving = true;
                                            });
                                            final payload = {
                                              "name": widget.name,
                                              "image_path": widget.imagePath,
                                              "goal": widget.goal,
                                              "description": widget.description,
                                              "calories": widget.calories,
                                              "protein": widget.protein,
                                              "carbs": widget.carbs,
                                              "fat": widget.fat,
                                              "fiber": widget.fiber,
                                              "water_liters": widget.waterLiters,
                                              if (widget.intakeText != null)
                                                "intake_text": widget.intakeText,
                                            };
                                            final res = await ApiServices.addDietPlan(
                                                payload: payload);
                                            if (!mounted) return;

                                            try {
                                              await context
                                                  .read<DietProvider>()
                                                  .refreshMyDiets();
                                            } catch (_) {
                                              // provider refresh optional
                                            }

                                            setState(() {
                                              _saving = false;
                                              if (res.status) {
                                                _alreadyAdded = true;
                                              }
                                            });

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(res.message),
                                                backgroundColor: res.status
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            );
                                          },
                                    child: const Text(
                                      'Add to MY Diet',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  // Popup Menu button (reusable)
                  const DietPopupMenu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
