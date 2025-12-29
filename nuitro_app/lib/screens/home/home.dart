import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/home/homepage_widgets/food_recomandation.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:nuitro/screens/Premium/premium_offer.dart';
import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/providers/diet_provider.dart';
import 'package:nuitro/providers/home_provider.dart';
import 'package:nuitro/models/home_models.dart';
import 'package:nuitro/home/Notifications/logged_food_details.dart';
import 'package:nuitro/home/Notifications/notification.dart';
import 'package:nuitro/screens/home/foodscan_screen.dart';
import 'package:nuitro/home/homepage_widgets/buuomnavigation.dart';
import 'package:nuitro/home/homepage_widgets/calender.dart';
import 'package:nuitro/home/homepage_widgets/hydration_tracking.dart';
import 'package:nuitro/home/homepage_widgets/wellness_Tracking.dart';
import 'package:nuitro/Progress/progress_widgets/progress.dart';
import 'package:nuitro/screens/wellness_calculator/wellness_tracking.dart';
import 'package:nuitro/services/api_helper.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<UserProvider>().ensureInitialized();
      await ApiHelper.ensureFreshAccessToken();
      if (!mounted) return;
      await context.read<DietProvider>().fetchMyDiets();
      if (!mounted) return;
      await context.read<HomeProvider>().loadHomeData(date: _selectedDate);
    });
  }

  double _targetForNutrient(String label, DietTargets targets) {
    final lower = label.toLowerCase();
    if (lower.contains('protein')) return targets.protein.toDouble();
    if (lower.contains('carb')) return targets.carbs.toDouble();
    if (lower.contains('fat')) return targets.fat.toDouble();
    if (lower.contains('fibre')) return targets.fiber.toDouble();
    return targets.calories.toDouble();
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
    });
    await ApiHelper.ensureFreshAccessToken();
    await context.read<HomeProvider>().loadHomeData(date: date);
  }

  Future<void> _refresh(HomeProvider provider) async {
    await context.read<UserProvider>().ensureInitialized();
    await ApiHelper.ensureFreshAccessToken();
    await context.read<DietProvider>().fetchMyDiets(forceRefresh: true);
    await provider.loadHomeData(date: _selectedDate);
  }

  IconData _iconForLabel(String label, int index) {
    switch (label.toLowerCase()) {
      case 'protein':
        return Icons.egg_outlined;
      case 'carbs':
        return Icons.breakfast_dining_outlined;
      case 'fats':
        return Icons.opacity;
      case 'fibre':
      case 'fiber':
        return Icons.energy_savings_leaf_outlined;
      default:
        const fallbackIcons = [
          Icons.monitor_weight_outlined,
          Icons.food_bank_outlined,
          Icons.restaurant_menu,
        ];
        return fallbackIcons[index % fallbackIcons.length];
    }
  }

  Color _colorForIndex(int index) {
    const colors = [
      Color.fromRGBO(255, 182, 182, 1),
      Color.fromRGBO(207, 215, 217, 1),
      Color.fromRGBO(226, 242, 255, 1),
      Color.fromRGBO(220, 250, 157, 1),
      Color.fromRGBO(255, 235, 193, 1),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final rawName = userProvider.user?.name.trim();
    final greetingName = (rawName != null && rawName.isNotEmpty) ? rawName : 'Guest';
    final homeProvider = context.watch<HomeProvider>();
    final dietProvider = context.watch<DietProvider>();
    final dietTargets = dietProvider.targets;
    final dashboard = homeProvider.dashboard;
    final consumedCalories = dashboard.consumedCalories;
    final int targetCalories =
        dietTargets.calories > 0 ? dietTargets.calories : dashboard.totalCalories;
    final double rawProgress = targetCalories <= 0
        ? 0
        : consumedCalories / targetCalories;
    final double progress = rawProgress.isFinite
        ? rawProgress.clamp(0.0, 1.0)
        : 0;
    final double accomplishedPercent =
        rawProgress.isFinite && targetCalories > 0
            ? (rawProgress * 100).clamp(0.0, 999.9)
            : 0;
    final nutrients = dashboard.nutrients;
    final meals = homeProvider.meals;
    final mealRawData = homeProvider.mealRawData;
    final hydration = dashboard.hydration;
    final wellnessPrompt = dashboard.wellnessPrompt;
    final predictions = homeProvider.predictions;
    final errorMessage = homeProvider.errorMessage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _refresh(homeProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.black),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (homeProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(),
                          ),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Container(
                        height: 80,
                        child: Row(
                          children: [
                            Image.asset('assets/images/profilephoto.png',width: 65,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.manrope(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Hello '),
                                        TextSpan(
                                          text: greetingName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Ready to crush your goals today?',
                                    style:  GoogleFonts.beVietnamPro(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,

                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.asset('assets/images/premium1.png'),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const GoPremium()),
                                );
                              },
                            ),

                            const SizedBox(width: 5),
                            GestureDetector(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child:
                                    Image.asset('assets/images/Notify Bell.png'),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Notificationsss()),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Calendar(
                        initialDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Container(
                          width: double.infinity,
                          height: 250,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(38, 50, 56, 1),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),

                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 8),
                                  Text(
                                    'Calories Consumed',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const Progress(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'View Report',
                                      style: TextStyle(
                                        color: Color.fromRGBO(220, 250, 157, 1),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),


                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: CustomPaint(
                                      size: const Size(220, 120),
                                      painter: ArcPainter(progress),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 30),
                                      const Icon(
                                        Icons.local_fire_department_outlined,
                                        color: Color(0xFF9EE37D),
                                      ),
                                      const Text(
                                        "Calories",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9EE37D),
                                        ),
                                      ),
                                      Text(
                                        consumedCalories.toString(),
                                        style: const TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9EE37D),
                                        ),
                                      ),
                                      Text(
                                        "of ${targetCalories.toString()} kcal",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${accomplishedPercent.toStringAsFixed(1)}% of target",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Builder(
                        builder: (context) {
                          const placeholderNutrients = <NutrientSummary>[
                            NutrientSummary(label: 'Protein', value: 0, maxValue: 100),
                            NutrientSummary(label: 'Carbs', value: 0, maxValue: 100),
                            NutrientSummary(label: 'Fats', value: 0, maxValue: 100),
                            NutrientSummary(label: 'Fibre', value: 0, maxValue: 100),
                          ];
                          final macroItems =
                              nutrients.isEmpty ? placeholderNutrients : nutrients;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: macroItems.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.65,
                                ),
                                itemBuilder: (context, index) {
                                  final nutrient = macroItems[index];
                                  final target = _targetForNutrient(nutrient.label, dietTargets);
                                  final double resolvedMax = target > 0
                                      ? target
                                      : (nutrient.maxValue <= 0 ? 100 : nutrient.maxValue);
                                  final double percent = resolvedMax > 0
                                      ? (nutrient.value / resolvedMax * 100).clamp(0.0, 100.0)
                                      : 0;
                                  final percentageLabel = target > 0
                                      ? "${percent.toStringAsFixed(1)}%"
                                      : null;
                                  return NutrientBar(
                                    label: nutrient.label,
                                    value: nutrient.value,
                                    maxValue: resolvedMax,
                                    icon: _iconForLabel(nutrient.label, index),
                                    customColor: _colorForIndex(index),
                                    // percentageLabel: percentageLabel,
                                  );
                                },
                              ),
                              if (nutrients.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    'Log your meals to personalise these macros.',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Recommended and Diet Reciepe',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      FoodRecommendation(predictions: predictions),

                      const SizedBox(height: 30),
                      WellnessTrackingPage(
                        question: wellnessPrompt.question.isEmpty
                            ? 'How are you feeling today?'
                            : wellnessPrompt.question,
                        options: wellnessPrompt.options.isEmpty
                            ? const ['Happy 😊', 'Low 😔', 'Sick 🤢', 'Energetic ⚡']
                            : wellnessPrompt.options,
                        selected: wellnessPrompt.selected,
                        onMenuTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WellnessTracking(),
                            ),
                          );
                        },
                        onOptionSelected: (mood) => context
                            .read<HomeProvider>()
                            .setWellnessMood(mood, date: _selectedDate),
                      ),
                      const SizedBox(height: 10),
                      HydrationTrackerPage(
                        goal: hydration.goal == 0 ? 2500 : hydration.goal,
                        intake: hydration.intake,
                        tip: hydration.tip.isNotEmpty
                            ? hydration.tip
                            : 'Log a glass to start your hydration streak!',
                        onLogWater: (amount) =>
                            context.read<HomeProvider>().logWaterIntake(amount, date: _selectedDate),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Todays Meal',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () async {
                                      await _refresh(homeProvider);
                                    },
                                    icon: const Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),

                              SizedBox(
                                height: 400,
                                width: 500,
                                child: homeProvider.isLoading
                                    ? const Center(child: CircularProgressIndicator()) // 🔄 show loader
                                    : meals.isEmpty
                                        ? const Center(child: Text("No meals found today")) // 📭 empty state
                                        : ListView.builder(
                                            itemCount: meals.length,
                                            physics: const BouncingScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              final meal = meals[index];
                                              final raw = index < mealRawData.length
                                                  ? mealRawData[index]
                                                  : <String, dynamic>{};
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => LoggedFoodDetails(
                                                              responseDataRaw: raw,
                                                            )),
                                                  );
                                                },
                                                child: MealCard(meal: meal),
                                              );
                                            },
                                          ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),


                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}


class NutrientBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final IconData icon;
  final Color customColor;
  final String? percentageLabel;

  const NutrientBar({
    Key? key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.icon,
    required this.customColor,
    this.percentageLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double safeMax = maxValue <= 0 ? 1 : maxValue;
    final double ratio = (value / safeMax).clamp(0.0, 1.0);

    return Container(
      width: double.infinity, // takes available space
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: customColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: Icon(icon, size: 20, color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          // Bar + Value Row
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.withOpacity(0.3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                "${value.toInt()}g",
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
              const Spacer(),
              Text(
                "${maxValue.toInt()}g",
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




class ArcPainter extends CustomPainter {
  final double progress;

  ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    const double startAngle = pi;
    const double sweepAngle = pi;

    /// ---- Background Arc (grey) ----
    final Paint bgPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    /// ---- Border Paint (thicker) ----
    final Paint borderPaint = Paint()
      ..color = Color.fromRGBO(173, 253, 5, 1) // <-- border color
      ..strokeWidth = 20 // slightly larger than progress arc
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, borderPaint);

    /// ---- Foreground Arc (main progress) ----
    final Paint fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi,
        endAngle: 2 * pi,
        colors: [
          const Color.fromRGBO(173, 253, 5, 1),
          const Color.fromRGBO(40, 12, 12, 1),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: 100,
      ))
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}






class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color.fromRGBO(220, 250, 157, 0.7),),

      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200, // fallback background
              child: ClipOval(
                child: Image.network(
                  meal.imageUrl,
                  width: 48, // double radius
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood, size: 30, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),

            /// Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Meal Name (1 line only)
                  Text(
                    meal.name,
                    style:  GoogleFonts.manrope(
                        fontWeight: FontWeight.w500, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  /// Calories (1 line only)
                  // Text(
                  //   "${meal.calories.toStringAsFixed(0)} kcal",
                  //   style: const TextStyle(
                  //       fontWeight: FontWeight.w700, fontSize: 12),
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: "${meal.calories.toStringAsFixed(0)}", // kcal value
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "calories", // only this part styled differently
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  /// Nutrients Row
                  Row(
                    children: [
                      Flexible(child: _nutrientItem("Protein", meal.protein)),
                      Flexible(child: _nutrientItem("Fat", meal.fat)),
                      Flexible(child: _nutrientItem("Fiber", meal.fiber)),
                    ],
                  ),
                ],
              ),
            ),

            /// Time container
            Align(alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.black),
                    const SizedBox(width: 3),
                    Text(
                      meal.time.isNotEmpty ? meal.time : "Lunch",
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _nutrientItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6, // 👈 small dot
            color: Colors.grey,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: "${value.toStringAsFixed(1)} ", // value part
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // black for value
                ),
                children: [
                  TextSpan(
                    text: label, // label part
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45, // grey for label
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}





