import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/screens/weight/weight_progress.dart';
import 'package:nuitro/services/api_helper.dart';
import 'challenges.dart';
import 'entries.dart';
import 'graph.dart';
import 'macro_card.dart';
class Calories extends StatefulWidget {
  const Calories({super.key});

  @override
  State<Calories> createState() => _CaloriesState();
}

class _CaloriesState extends State<Calories> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<UserProvider>().ensureInitialized();
      await ApiHelper.ensureFreshAccessToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
            CalorieChartScreen(),
            SizedBox(height: 10,),

            Entries(),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeightProgress ()),
                );
              },
              child: Container(alignment:Alignment.center,height:60,width:double.infinity,decoration: BoxDecoration(color:Color.fromRGBO(220, 250, 157, 1),borderRadius: BorderRadius.circular(10), ),child:
              Text('Weight Progress',style: TextStyle(fontSize:18 ,fontWeight:FontWeight.w500 ,color:Colors.black ),),),
            ),

            SizedBox(height: 10,),
            SizedBox(height: 10,),
            MacroDistributionCard(),
            SizedBox(height: 10,),
            Challenges()
        ],
        
        
        
        
        ),
      )


    ;
  }
}
