import 'package:flutter/material.dart';
class RewardLevel {
  final String level;
  final String title;
  final String subtitle;
  final String date;

  const RewardLevel({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.date,
  });
}


class RewardsPage extends StatelessWidget {
  const RewardsPage({Key? key}) : super(key: key);


  final List<RewardLevel> levels = const [
    RewardLevel(level: 'Lvl-1', title: '1 day Streak', subtitle: 'First initial logged', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-2', title: '5 days Streak', subtitle: 'Water Challenge', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-3', title: '30 days Streak', subtitle: 'Protein', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-4', title: '70 days Streak', subtitle: 'Integrity Goal', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-5', title: '140 days Streak', subtitle: 'Mindfulness Goal', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-6', title: '205 days Streak', subtitle: 'Exercise Goal', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-7', title: '270 days Streak', subtitle: 'Careers Target', date: 'July 30, 2025'),
    RewardLevel(level: 'Lvl-8', title: '365 days Streak', subtitle: 'Resilience Goal', date: 'July 30, 2025'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false, // keep title aligned left
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Go back
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // black circular background
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: const Text(
          'Personal Rewards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // 2-column grid for rewards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 0.8, // adjust height vs width
                children: levels.map((level) {
                  return RewardCard(
                    level: level.level,
                    title: level.title,
                    subtitle: level.subtitle,
                    date: level.date,
                    leadingPlaceholder: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),
            StartChallengeCard(
              onStart: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Start tapped')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RewardCard extends StatelessWidget {
  final String level;
  final String title;
  final String subtitle;
  final String date;
  final Widget leadingPlaceholder;

  const RewardCard({
    Key? key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.leadingPlaceholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(226, 242, 255, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon / placeholder at top
            Container(width:104,height:120,decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),color: Colors.white),child:

            Column(crossAxisAlignment: CrossAxisAlignment.center,children: [

              Text(
                level,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                
              ),

              SizedBox(height:80,child: Image.asset('assets/images/badge.png'))

            ],),),




            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),


            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),


            Text(
              date,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class StartChallengeCard extends StatelessWidget {
  final VoidCallback onStart;
  const StartChallengeCard({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        child: Row(
          children: [
            // Empty placeholder where an icon or badge could go
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
            ),
            const SizedBox(width: 12),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Start protein challenge',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Log 2 protein meal to mark 1 day',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Start button
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(220, 250, 157, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
