import 'package:flutter/material.dart';

import 'package:nuitro/home/Notifications/nutrition_card.dart';
import 'package:nuitro/home/Notifications/update_log.dart';
import 'mood_trend.dart';
class WellnessTracking extends StatefulWidget {
  const WellnessTracking({super.key});

  @override
  State<WellnessTracking> createState() => _WellnessTrackingState();
}

class _WellnessTrackingState extends State<WellnessTracking> {
  @override
  Widget build(BuildContext context) {
    double _selectedWeight = 7.0;
    final nutritionData = {
      "energy": 1271,
      "fat": 9,
      "saturatedFat": 5,
      "polyFat": 4,
      "monoFat": 7,
      "cholestrol": 114,
      "fiber": 0,
      "sugar": 0,
      "sodium": 503,
      "potassium": 272,
    };
    return Scaffold(backgroundColor: Colors.white,

    body: SafeArea(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
      child:SingleChildScrollView(
        child: Column(
          children: [
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
              Text('Wellness Tracking',style: TextStyle(fontWeight:FontWeight.w600,fontSize: 24 ),)
             ,IconButton(onPressed: (){}, icon:Icon(Icons.cancel,size: 40,) ),
            ],),
            SizedBox(height: 30,),
            Center(child: Text('Energy Scale',style: TextStyle(fontSize:17,fontWeight: FontWeight.w400 ),),),
            Container( decoration: BoxDecoration(
              color: Colors.white, // background color
              border: Border.all(
                color: Color.fromRGBO(237, 239, 241, 1),  // border color
                width: 2,            // border thickness
              ),
              borderRadius: BorderRadius.circular(25), // rounded corners
            ),

              child: Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                child: WeightPicker(
                  minWeight:  1,
                  maxWeight: 100,

                  selectedWeight: _selectedWeight,
                  onChanged: (newWeight) {
                    setState(() {
                      _selectedWeight = newWeight;
                    });
                  },
                ),
              ),
            ),


            SizedBox(height: 15,),
            MoodTrendScreen(),
        
            SizedBox(height: 15,),
            NutritionCard(editDeleteEnable: false,
              nutritionData: nutritionData,
              onDelete: () {
                // handle delete
                debugPrint("Delete pressed");
              },
              onEdit: () {
                // Navigate to Edit Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdateLog()),
                );
              },)
          ],
        ),
      ) ,),),

    );
  }
}



class WeightPicker extends StatefulWidget {
  final int minWeight;
  final int maxWeight;

  final double selectedWeight;
  final ValueChanged<double> onChanged;

  const WeightPicker({
    Key? key,
    required this.minWeight,
    required this.maxWeight,

    required this.selectedWeight,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  late ScrollController _scrollController;
  final double _itemExtent = 30.0; // closer spacing between ticks

  @override
  void initState() {
    super.initState();
    final initialOffset =
        (widget.selectedWeight - widget.minWeight) * _itemExtent;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final center = _scrollController.position.viewportDimension / 2;
    final offset = _scrollController.offset + center;
    final index = (offset / _itemExtent).round();
    final weight = widget.minWeight + index;

    if (weight >= widget.minWeight && weight <= widget.maxWeight) {
      widget.onChanged(weight.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    final weights = List.generate(
      widget.maxWeight - widget.minWeight + 1,
          (index) => widget.minWeight + index,
    );

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _onScroll();
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: weights.length,
              itemBuilder: (context, index) {
                final value = weights[index];

                // compute center alignment
                final center = _scrollController.position.viewportDimension / 2;
                final offset = _scrollController.offset + center;
                final currentIndex = (offset / _itemExtent).round();
                final isSelected = index == currentIndex;

                final isMajorTick = value % 5 == 0;

                return SizedBox(
                  width: _itemExtent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Number ABOVE tick (only on major ticks)
                      if (isMajorTick)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 18 : 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),

                      // Tick mark
                      Container(
                        width: 2,
                        height: isMajorTick ? 25 : 12,
                        color: isSelected ? Colors.black : Colors.grey.shade400,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Center indicator
          const Positioned(
            top: 0,
            child: Icon(Icons.arrow_drop_down,
                size: 32, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
