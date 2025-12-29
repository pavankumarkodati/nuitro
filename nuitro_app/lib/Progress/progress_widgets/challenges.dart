import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nuitro/screens/weight/fitness_stat.dart';
import '../../Weight/weight_widgets/progress_gramafication.dart';

class Challenges extends StatelessWidget {
  const Challenges({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenges Title
              Text(
                "Challenges",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Challenges Cards (Horizontal)
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(onTap:
                    (){Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AchievementsPage()),
                    );
                    },

                      child: _ChallengeCard(
                        icon: Icons.directions_run,
                        title: "7 days Streak Fitness",
                        subtitle: "2 Activities Left",
                        calories: "-545 kcal burnt",
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ChallengeCard(
                      icon: Icons.local_drink,
                      title: "5 Glass Water",
                      subtitle: "2 Left",
                      calories: "",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Protein Boost Tip Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(226, 242, 255, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          "Protein Boost Tip:",
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _bulletText("Try adding chicken or lentils to your meals."),
                    _bulletText("Add 20-min strength training to support muscle growth."),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Activity Title
              Text(
                "Activity",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Activity Card
              GestureDetector(onTap:
                  (){Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkoutsScreen ()),
              );},
                child: _ActivityCard(
                  icon: Icons.directions_run,
                  title: "Activities",
                  subtitle: "4 Activities",
                  calories: "-545 kcal burnt",
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Challenge Card Widget
class _ChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String calories;

  const _ChallengeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center,
      width: 306,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.grey.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  
                ),
                const SizedBox(height: 4),
               Expanded(
                 child: Row(children: [ Text(
                   subtitle,

                   style: GoogleFonts.manrope(
                     fontSize: 12,
                     color: Colors.black54,
                   ),
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                 ),
                   if (calories.isNotEmpty)
                     Flexible(
                       child: Text(
                         calories,
                         style: GoogleFonts.manrope(
                           fontSize: 12,
                           color: Colors.red,
                           fontWeight: FontWeight.w600,
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),],),
               )
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}

// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String calories;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.grey.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [ Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                  Text(
                    calories,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),],)

              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}
