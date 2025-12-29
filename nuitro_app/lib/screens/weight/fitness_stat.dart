import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  // Example data model: list of items with icon, title and optional action
  final List<_WorkoutItem> _items = [
    _WorkoutItem(title: 'Bicep', icon: Icons.fitness_center, onTap: () => debugPrint('Bicep tapped')),
    _WorkoutItem(title: 'Body-Back', icon: Icons.self_improvement, onTap: () => debugPrint('Body-Back tapped')),
    _WorkoutItem(title: 'Body-Butt', icon: Icons.accessibility_new, onTap: () => debugPrint('Body-Butt tapped')),
    _WorkoutItem(title: 'Legs and Core', icon: Icons.directions_run, onTap: () => debugPrint('Legs & Core tapped')),
    _WorkoutItem(title: 'Pectoral machine', icon: Icons.sports_handball, onTap: () => debugPrint('Pectoral machine tapped')),
    _WorkoutItem(title: 'Legs & Core', icon: Icons.fitness_center, onTap: () => debugPrint('Legs & Core 2 tapped')),
    _WorkoutItem(title: 'Weight bench', icon: Icons.event_seat, onTap: () => debugPrint('Weight bench tapped')),
    _WorkoutItem(title: 'Weight loss', icon: Icons.monitor_heart, onTap: () => debugPrint('Weight loss tapped')),
    _WorkoutItem(title: 'Woman up front', icon: Icons.person, onTap: () => debugPrint('Woman up front tapped')),
  ];

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 16;

    return Scaffold(backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
          child: Column(
            children: [
              // Top row: back button + title
              Row(
                children: [
                  // circular back button
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // pop or any action
                      Navigator.of(context).maybePop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18,color: Colors.white,),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'WORKOUTS',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Expanded list
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  padding: const EdgeInsets.only(bottom: 18),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _WorkoutRow(
                      title: item.title,
                      icon: item.icon,
                      // pass index so you can use switch or direct callback
                      onTap: () {
                        // Example: call the item-specific function
                        item.onTap?.call();

                        // You can also handle different behaviour by index:
                        // if (index == 0) Navigator.push(...);
                      },
                    );
                  },
                ),
              ),

              // Bottom info card with a 'Start' button
              const SizedBox(height: 8),
              _BottomInfoCard(
                title: '30min workout streak',
                subtitle: 'Finish Activity to mark 1 day',
                onStart: () {
                  // Start button pressed
                  debugPrint('Start pressed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small model to keep data tidy
class _WorkoutItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  _WorkoutItem({required this.title, required this.icon, this.onTap});
}

/// Single list row widget (rounded green pill with icon, text, trailing arrow)
class _WorkoutRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _WorkoutRow({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // green background like image
    final bg = BoxDecoration(
      color: Color.fromRGBO(220, 250, 157, 1) // very light green
     , borderRadius: BorderRadius.circular(14),

    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: bg,
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            // optional small indicator dot (you can show conditionally)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

/// Bottom card with text + start button
class _BottomInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onStart;

  const _BottomInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // card look
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // left: small icon + title/subtitle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department_outlined, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 14)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),

          // Start button
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(220, 250, 157, 1) , // pale green like design
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
