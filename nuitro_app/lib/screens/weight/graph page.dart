import 'package:flutter/material.dart';
import 'package:nuitro/Weight/weight_widgets/graph.dart';

import 'diet_details.dart';
import 'fitness_stat.dart';

class ActiveCaloriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // Handle back button press
                  },
                ),
                Text(
                  'FITNESS',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

              ],),
              Container(height:400,child: FitnessPage()),
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                Text(
                  'Active Calories',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          '7 days',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.more_vert, color: Colors.grey[700]),
                      ],
                    ),
                  ),
                ),

              ],),
              // Calorie Summary
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCalorieStat(Icons.favorite_border, '246 Kcal', 'Last 7 days'),
                  _buildCalorieStat(Icons.lock_outline, '84k Kcal', 'All Time'),
                  _buildCalorieStat(Icons.flash_on, '72 Kcal', 'Average'),
                ],
              ),
              SizedBox(height: 32),

              // Challenge Activities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Challenge Activities',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap:(){Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutsScreen()),
                    );}
                    ,
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildActivityTile(context,'Bicep', Icons.fitness_center),
              _buildActivityTile(context,'Body-Back', Icons.accessibility),
              _buildActivityTile(context,'Body-Butt', Icons.airline_seat_legroom_reduced), // Placeholder icon
              _buildActivityTile(context,'Legs and Core', Icons.nordic_walking),
              SizedBox(height: 32),

              // Weight Loss Tip
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight loss Tip:',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Great job! You\'re down 1kg this month. Try adding 10g protein daily to maintain muscle.',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(BuildContext context,String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap:(){Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  FitnessDetailPage()),
        );}
          ,
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(220, 250, 157, 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.black),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700], size: 16),
            onTap: () {
              // Handle activity tile tap
            },
          ),
        ),
      ),
    );
  }
}

// To run this code, you'd typically have a main.dart file like this:
/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ActiveCaloriesPage(),
    );
  }
}
*/