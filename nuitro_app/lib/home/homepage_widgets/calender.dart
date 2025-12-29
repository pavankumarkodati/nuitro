import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class Calendar extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;

  const Calendar({super.key, this.initialDate, this.onDateSelected});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const List<String> _dayAbbreviations = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late List<DateTime> weekDates;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    _setWeekDates(widget.initialDate ?? DateTime.now(), notify: false);
  }

  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DateTime previous = oldWidget.initialDate ?? DateTime.now();
    final DateTime current = widget.initialDate ?? previous;
    if (!_isSameDay(previous, current)) {
      _setWeekDates(current, notify: true);
    }
  }

  List<DateTime> _generateWeekDates(DateTime referenceDate) {
    final startOfWeek = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    return List<DateTime>.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _setWeekDates(DateTime referenceDate, {required bool notify}) {
    final dates = _generateWeekDates(referenceDate);
    final index = dates.indexWhere((date) => _isSameDay(date, referenceDate));
    if (notify) {
      setState(() {
        weekDates = dates;
        selectedIndex = index >= 0 ? index : 0;
      });
    } else {
      weekDates = dates;
      selectedIndex = index >= 0 ? index : 0;
    }
  }

  void _handleSelection(int index) {
    if (selectedIndex == index) {
      widget.onDateSelected?.call(weekDates[index]);
      return;
    }
    setState(() {
      selectedIndex = index;
    });
    widget.onDateSelected?.call(weekDates[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: 388,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Color.fromRGBO(67, 67, 67, 0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weekDates.length,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          itemBuilder: (context, index) {
            bool isSelected = selectedIndex == index;
            final date = weekDates[index];
            return GestureDetector(
              onTap: () => _handleSelection(index),
              child: Container(
                width: 44,
                height: 79,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Color.fromRGBO(220, 250, 157, 1) : Color.fromRGBO(67, 67, 67, 0),
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayAbbreviations[date.weekday % 7],
                      style: GoogleFonts.manrope(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.black : Color.fromRGBO(67, 67, 67, 0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black,

                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
