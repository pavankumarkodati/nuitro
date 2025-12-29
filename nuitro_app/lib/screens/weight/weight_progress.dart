import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/weight_models.dart';
import 'package:nuitro/screens/weight/weight_scaning.dart';
import 'package:nuitro/Weight/weight_widgets/body_mass_index.dart';
import 'package:nuitro/Weight/weight_widgets/weight_entries.dart';
import 'package:nuitro/Weight/weight_widgets/weight_graph.dart';
import 'package:nuitro/providers/weight_provider.dart';

import 'package:nuitro/More/custom_back_button2.dart';
import 'package:nuitro/Progress/progress_widgets/macro_card.dart';

class WeightProgress extends StatefulWidget {
  const WeightProgress({super.key});

  @override
  State<WeightProgress> createState() => _WeightProgressState();
}

class _WeightProgressState extends State<WeightProgress> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WeightProvider>();
      if (!provider.hasLoadedOnce) {
        provider.fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weightProvider = context.watch<WeightProvider>();
    final dashboard = weightProvider.dashboard;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                    ),
            
                    const Text(
                      "Weight Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            
                    // Expand button
                    GestureDetector(onTap: (){Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WeightScanning()),
                    );},
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(220, 250, 157, 1), // light green
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Icon(Icons.fullscreen, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: 24),
            
                /// Progress Card
                _WeightGoalCard(dashboard: dashboard),
                const SizedBox(height: 15),
                const WeightChartScreen(),
                const SizedBox(height: 15),
                EntriesScreen(entries: dashboard.entries),
                const SizedBox(height: 15),
                BmiCard(bmi: dashboard.bmi),
                const MacroDistributionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeightGoalCard extends StatelessWidget {
  const _WeightGoalCard({required this.dashboard});

  final WeightDashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    final double progress = dashboard.progressPercent.clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 49,
                    height: 49,
                    child: CircularProgressIndicator(
                      value: progress == 0 ? null : progress,
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation(
                        Color.fromRGBO(220, 250, 157, 1),
                      ),
                      backgroundColor: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    progress == 0 ? "--" : "${(progress * 100).round()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're going to reach your goal by",
                  style: GoogleFonts.zenKakuGothicAntique(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatGoalDate(dashboard.projectedGoalDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit, color: Colors.white),
        ],
      ),
    );
  }

  static String _formatGoalDate(DateTime? date) {
    if (date == null) {
      return 'Set your goal date';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
