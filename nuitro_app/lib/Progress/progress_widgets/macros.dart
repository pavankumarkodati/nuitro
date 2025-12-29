import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'macro_entries.dart';
import 'macros_graph.dart';
class Macros extends StatefulWidget {
  const Macros({super.key});

  @override
  State<Macros> createState() => _MacrosState();
}

class _MacrosState extends State<Macros> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MacrosGraph(),
          SizedBox(height: 10,),

          MacroEntries(),
          SizedBox(height: 10,),
          Container(alignment:Alignment.center,height:60,width:double.infinity,decoration: BoxDecoration(color:Color.fromRGBO(220, 250, 157, 1),borderRadius: BorderRadius.circular(10), ),child:
          Text('Weight Progress',style: TextStyle(fontSize:18 ,fontWeight:FontWeight.w500 ,color:Colors.black ),),),

          SizedBox(height: 10,),

          SizedBox(height: 10,),
          _ActivityCard(
            icon: Icons.directions_run,
            title: "Activities",
            subtitle: "4 Activities",
            calories: "-545 kcal burnt",
          ),
        ],




      ),
    );
  }
}



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






