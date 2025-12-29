import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/diet_plan.dart';
import 'package:nuitro/providers/diet_provider.dart';
import 'package:nuitro/screens/meal_diet/all_diets.dart';
import 'package:nuitro/screens/meal_diet/diet_details.dart';

class MyDietsPage extends StatefulWidget {
  const MyDietsPage({super.key, this.useScaffold = true});

  final bool useScaffold;

  @override
  State<MyDietsPage> createState() => _MyDietsState();
}

class _MyDietsState extends State<MyDietsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DietProvider>();
      if (!provider.hasLoadedOnce) {
        provider.fetchMyDiets();
      }
    });
  }

  Widget _buildContent() {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        final List<DietPlan> myDiets = provider.myDiets;

        Widget buildEmptyState() {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                height: 470,
                width: 264,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Image(
                      image: AssetImage('assets/images/Sign In.png'),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'No Diet Plans Yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start a personalized diet to make tracking even easier.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(220, 250, 157, 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await context.read<DietProvider>().refreshMyDiets();
                          } catch (_) {
                            // Ignore refresh errors here; fall back to navigation
                          }
                          if (!mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllDietsPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Get Diet Plan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        Widget buildSavedCard(DietPlan plan) {
          final title = plan.name
              .replaceAll(RegExp(r'[0-9]'), '')
              .replaceAll(RegExp(r'[^\x00-\x7F]+'), '');

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DietDetails(
                    name: title,
                    imagePath: plan.imageUrl.isNotEmpty ? plan.imageUrl : 'assets/images/Food.png',
                    goal: plan.goal,
                    description: plan.description,
                    calories: plan.calories,
                    protein: plan.protein,
                    carbs: plan.carbs,
                    fat: plan.fat,
                    fiber: plan.fiber ?? 0,
                    waterLiters: plan.waterLiters ?? 0,
                    intakeText: plan.intakeText.isEmpty ? null : plan.intakeText,
                    existingDietId: plan.id,
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: plan.imageUrl.isEmpty
                          ? Image.asset(
                              'assets/images/Food.png',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              plan.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/Food.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 1,
                          children: [
                            Text(
                              "${plan.calories} kcal | Protein:${plan.protein}g | Carbs:${plan.carbs}g | Fat:${plan.fat}g",
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget buildSavedList() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color.fromRGBO(221, 192, 255, 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Diet Plan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Continue with your personalized plan to stay on track.',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Saved Diet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              ...myDiets.map(buildSavedCard),
            ],
          );
        }

        if (provider.isLoading && !provider.hasLoadedOnce) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: provider.refreshMyDiets,
          child: SingleChildScrollView(
            physics: widget.useScaffold
                ? const AlwaysScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: widget.useScaffold ? 20 : 0,
              vertical: widget.useScaffold ? 10 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                if (provider.errorMessage != null &&
                    provider.errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: provider.refreshMyDiets,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        )
                      ],
                    ),
                  )
                else if (myDiets.isEmpty)
                  buildEmptyState()
                else
                  buildSavedList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.useScaffold
        ? SafeArea(child: _buildContent())
        : _buildContent();

    if (!widget.useScaffold) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Diets'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: body,
    );
  }
}


