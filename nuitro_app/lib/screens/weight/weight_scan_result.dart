import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/weight/weight_scaning.dart';
import 'package:nuitro/Weight/weight_widgets/body_mass_index.dart';
import 'package:nuitro/Weight/weight_widgets/weight_chart.dart';
import 'package:nuitro/models/weight_models.dart';

class WeightScanResult extends StatefulWidget {
  const WeightScanResult({super.key});

  @override
  State<WeightScanResult> createState() => _WeightScanResultState();
}

class _WeightScanResultState extends State<WeightScanResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
    body: SafeArea(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10)

    ,child: SingleChildScrollView(
      child: Column(children: [
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
                "Weight Scan Result",
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
          SizedBox(height: 15,),
          SizedBox(child: 
            Image.asset('assets/images/weightpic.png'),),
        SizedBox(height: 15,),
          WeightChartScreen2(),
          SizedBox(height: 15,),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Weight Data",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRow("Current weight", "65 kg"),
                _buildRow("Your goal", "72 kg"),
                _buildRow("Weight gain", "0.75kg / day"),
                _buildRow("Intensity", "Steady"),
              ],
            ),
          ),
          SizedBox(height: 10,),
          const BmiCard(
            bmi: WeightBmiInfo(
              score: 21.2,
              status: 'Normal',
              minRange: 18.5,
              maxRange: 24.9,
            ),
          ),
       SizedBox(height: 20,),
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
              'Save Log',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      
        ],),
    ),)),);
  }
}















Widget _buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:GoogleFonts.manrope(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
