
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FitnessDetailPage extends StatelessWidget {
  const FitnessDetailPage({Key? key}) : super(key: key);

  // Helper widget to build the Kcal stat columns
  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 28),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Food.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Dimmed Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // 3. Back and Menu Icons
          Positioned(
            top: statusBarHeight + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {},
            ),
          ),
          Positioned(
            top: statusBarHeight + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ),
          // 4. Main Content Area (White Card)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.7,
              width: screenWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: SingleChildScrollView( // <-- Make scrollable
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Body Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Kcal Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(Icons.favorite_border, '246 Kcal', 'Last 7 days'),
                          _buildStatColumn(Icons.local_fire_department, '84K Kcal', 'All Time'),
                          _buildStatColumn(Icons.flash_on, '72 Kcal', 'Average'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Informations Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            'Informations',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                       Text(
                        'Shift stubborn body fat and build muscle with this total-body workout.',
                        style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 10),
                       Text(
                        'If you\'re an experienced gym-goer hitting the weights room for long sessions several times a week, the chances are you have a structured training plan that targets different areas of the body with each workout.',
                        style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 30),
                      // Goal Section
    Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
    color: const Color.fromRGBO(226, 242, 255, 1),
    borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Icon(Icons.adjust, color: Colors.black, size: 30),
    const SizedBox(width: 15),
    Expanded( // 👈 allows text to wrap instead of overflowing
    child: Text(
    'Heart Health, Weight Maintenance',
    softWrap: true,
    style: GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 20),
                      // Mark Complete Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Mark Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Extra space at bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 5. Circular Profile Image
          Positioned(
            top: screenHeight * 0.25 - (screenWidth * 0.125),
            left: screenWidth / 2 - (screenWidth * 0.125),
            child: CircleAvatar(
              radius: screenWidth * 0.125,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: screenWidth * 0.12,
                backgroundImage: const AssetImage('assets/images/Food.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}