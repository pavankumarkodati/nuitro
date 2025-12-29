import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionCard extends StatelessWidget {
  final Map<String, dynamic> nutritionData;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool editDeleteEnable;

  const NutritionCard({
    Key? key,
    required this.nutritionData,
    required this.onDelete,
    required this.onEdit,
    this.editDeleteEnable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children:[
          Text(
            "Macro-nutrient:",
            style: const TextStyle(
              fontSize:15 ,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Card(
          elevation: 0,
          color: const Color.fromRGBO(220, 250, 157, 0.7), // light green background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Header row with actions
                if (editDeleteEnable)Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),

                /// Nutrient rows
                _buildNutrientRow("Energy", "${nutritionData['energy']} kJ"),
                const SizedBox(height: 8),
                _buildNutrientRow("Fat", "${nutritionData['fat']} g"),

                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      _buildGreyNutrientRow("Saturated fat", "${nutritionData['saturatedFat']} g",),
                      _buildGreyNutrientRow("Polyunsaturated fat", "${nutritionData['polyFat']} g"),
                      _buildGreyNutrientRow("Monounsaturated fat", "${nutritionData['monoFat']} g"),
                    ],
                  ),
                ),

                Divider(color: Colors.grey.shade300,),


                _buildNutrientRow("Cholestrol", "${nutritionData['cholestrol']} mg"),
                Divider(color: Colors.grey.shade300,),
                _buildNutrientRow("Fiber", "${nutritionData['fiber']} g"),
                _buildNutrientRow("Sugar", "${nutritionData['sugar']} g"),
                Divider(color: Colors.grey.shade300,),
                _buildNutrientRow("Sodium", "${nutritionData['sodium']} mg"),
                _buildNutrientRow("Potassium", "${nutritionData['potassium']} mg"),
              ],
            ),
          ),
        ),
         ] ),
    );
  }


  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
          Text(value,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(97, 125, 121,1),
              )),
        ],
      ),
    );



  }



  Widget _buildGreyNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(117, 117, 117, 1) ,
              )),
          Text(value,
              style:GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(67, 67, 67, 1),
              )),
        ],
      ),
    );



  }
}

//  usage
