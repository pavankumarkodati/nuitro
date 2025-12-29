import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nuitro/screens/onboarding/onboarding_page_1.dart';
import 'package:nuitro/screens/onboarding/splash_screen_1.dart';
import 'package:nuitro/screens/premium/premium.dart';
import 'package:nuitro/screens/auth/email_verification.dart';
import 'package:nuitro/screens/auth/forgot_password_screen.dart';
import 'package:nuitro/screens/auth/reset_password_screen.dart';
import 'package:nuitro/screens/auth/signup_screen.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_2.dart';
import 'package:nuitro/screens/profile_setup/profile_setup_4.dart';
import 'package:nuitro/screens/profile_setup/profile_splash_screen.dart';
import 'package:nuitro/Progress/progress_widgets/calories.dart';
import 'package:nuitro/Progress/progress_widgets/challenges.dart';
import 'package:nuitro/Progress/progress_widgets/entries.dart';
import 'package:nuitro/Weight/weight_widgets/body_mass_index.dart';
import 'package:nuitro/home/Notifications/barcode_scan_result.dart';
import 'package:nuitro/home/Notifications/home_screen_controller.dart';
import 'package:nuitro/home/Notifications/logs.dart';
import 'package:nuitro/home/Notifications/manual_log.dart';
import 'package:nuitro/home/Notifications/notification.dart';
import 'package:nuitro/home/Notifications/voice_log.dart';
import 'package:nuitro/screens/meal_diet/chat_bot.dart';
import 'package:nuitro/screens/meal_diet/diet_details.dart';
import 'package:nuitro/screens/meal_diet/diets.dart';
import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/providers/home_provider.dart';
import 'package:nuitro/providers/progress_provider.dart';
import 'package:nuitro/providers/scan_workflow_provider.dart';
import 'package:nuitro/providers/diet_provider.dart';
import 'package:nuitro/providers/weight_provider.dart';
import 'package:nuitro/services/secure_storage.dart';
import 'package:nuitro/services/api_helper.dart';
import 'package:nuitro/settings/Favorite.dart';
import 'package:nuitro/settings/Integration.dart';
import 'package:nuitro/settings/change_password.dart';

import 'screens/profile_setup/profile_setup_1.dart';
import 'screens/profile_setup/profile_setup_3.dart';
import 'screens/profile_setup/profile_setup_5.dart';
import 'Progress/progress_widgets/graph.dart';
import 'Progress/progress_widgets/macros.dart';
import 'Progress/progress_widgets/macros_graph.dart';
import 'Weight/weight_widgets/personal_reward.dart';
import 'Weight/weight_widgets/progress_gramafication.dart';
import 'Weight/weight_widgets/weight_chart.dart';
import 'Weight/weight_widgets/weight_entries.dart';
import 'Weight/weight_widgets/weight_graph.dart';
import 'home/Notifications/manual_log_card.dart';
import 'home/Notifications/manual_log_search_result.dart';
import 'screens/meal_diet/nutrient_calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  print("token");
  String? token= await TokenStorage.getAccessToken();
  print(token);
  if (token != null && token.isNotEmpty) {
    await ApiHelper.ensureFreshAccessToken();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..ensureInitialized()),
        ChangeNotifierProvider(create: (_) => HomeProvider()..loadHomeData()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ScanWorkflowProvider()),
        ChangeNotifierProvider(create: (_) => DietProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
      ],
      child: MyApp(token: token),
    ),
  );
}

class MyApp extends StatelessWidget {

  final String? token;

  const MyApp({required String? this.token, super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),

        ),//  Default font = Poppins

      title: 'Flutter Demo',

      home:Scaffold(backgroundColor: Colors.white,body: SafeArea(child:
     // Settings(userName: "Andrew", userImage: "assets/images/Splashscreen2.png")

      this.token==null ? SplashScreen() : HomeScreenController(),

      )),
    );
  }
}
