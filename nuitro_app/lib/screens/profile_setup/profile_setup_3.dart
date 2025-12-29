import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/components/global_Constants.dart';
import 'package:nuitro/components/profile_submit_button.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_4.dart';

import 'package:nuitro/components/multi_colour_button.dart';
import 'package:nuitro/components/top_back_button.dart';
class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  bool _isKg = false;
  double _selectedWeight = 70.0;
  late ScrollController _scrollController;
   int currentPage = 3;

  final int totalPages = 8;

  final double _rulerUnitWidth = 10.0;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToWeight());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToWeight() {
    final double minWeight = _isKg ? 20.0 : 45.0;
    final offset = (_selectedWeight - minWeight) * _rulerUnitWidth;
    _scrollController.jumpTo(offset);
  }
  @override
  Widget build(BuildContext context) {
    double progress = currentPage / totalPages;
    final double minWeight = _isKg ? 20.0 : 45.0;
    final double maxWeight = _isKg ? 200.0 : 440.0;
    final int totalUnits = (maxWeight - minWeight).toInt();
    return  Scaffold(backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5,),
              CustomBackButton(),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: "$currentPage",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "/$totalPages",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
               Text(
                "What's your \n weight?",
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ), textAlign: TextAlign.center,),
              const SizedBox(height: 8),
              Text(
                'This helps us to calculate your BMI and personalize your goals.',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(117, 117, 117, 1)
                ),  textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              Center(
                child: MultiColourButton(leftButton: 'lb', rightButton: 'kg', leftButtonTap: (){setState(() {
                  _isKg=false;
                });}, rightButtonTap: (){setState(() {
                  _isKg=true;
                });}, isLeftSelected:_isKg ),
              )
              ,  const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 8),

                          Text(
                            '${_selectedWeight.toStringAsFixed(1)} ${_isKg ? 'Kg' : 'lb'}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),

                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollUpdateNotification) {
                                  final newWeight = (notification.metrics.pixels / _rulerUnitWidth) + minWeight;
                                  setState(() {
                                    _selectedWeight = newWeight;
                                  });
                                }
                                return true;
                              },
                              child: Container( decoration: BoxDecoration(
                                color: Colors.white, // background color
                                border: Border.all(
                                  color: Color.fromRGBO(237, 239, 241, 1),  // border color
                                  width: 2,            // border thickness
                                ),
                                borderRadius: BorderRadius.circular(25), // rounded corners
                                   ),

                                child: Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                  child: WeightPicker(
                                    minWeight: _isKg ? 20 : 45,
                                    maxWeight: _isKg ? 200 : 440,
                                    useLbs: !_isKg,
                                    selectedWeight: _selectedWeight,
                                    onChanged: (newWeight) {
                                      setState(() {
                                        _selectedWeight = newWeight;
                                      });
                                    },
                                  ),
                                ),
                              ),


                            ),
                            // Center indicator

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ProfileSubmitButton(
                progress: currentPage / totalPages,
                onNext: () {
                  setState(() {

                    globalUserProfile.weight=_selectedWeight;
                    // move to next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Page4()),
                    );
                  });
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}









class WeightPicker extends StatefulWidget {
  final int minWeight;
  final int maxWeight;
  final bool useLbs;
  final double selectedWeight;
  final ValueChanged<double> onChanged;

  const WeightPicker({
    Key? key,
    required this.minWeight,
    required this.maxWeight,
    required this.useLbs,
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
