import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/More/more.dart';
import 'package:nuitro/settings/Favorite.dart';
import 'package:nuitro/settings/change_password.dart';
import 'package:nuitro/settings/notification.dart';
import 'package:nuitro/settings/profile.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/screens/home/foodscan_screen.dart';
import 'package:nuitro/home/homepage_widgets/buuomnavigation.dart';
import 'package:nuitro/providers/auth_provider.dart';
import 'Integration.dart';

class Settings extends StatelessWidget {
  final String userName;
  final String userImage;

  const Settings({
    Key? key,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  Widget buildMenuItem(String text, {VoidCallback? onTap, bool enabled = true}) {
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.manrope(
          color: enabled ? Colors.white : Colors.grey,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: enabled ? Colors.white : Colors.grey, size: 18),
      onTap:  onTap ,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Settings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
            
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [Stack(children: [
                     Image.asset('assets/images/profilephoto.png')]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(text:TextSpan(
                           text:  "Hello",
                              style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                                      children:[ TextSpan(
                                        text:  " $userName,",
                                        style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),]
                        
                            ),
                        
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ready to crush your goals today?",
                              softWrap: true,
                              style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 12,fontWeight: FontWeight.w300),
                            ), ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
            
                // Black container with menu items
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      buildMenuItem("Profile",onTap: (){  Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => ProfilePage(name:user?.name ?? 'Guest' , email:user?.name ?? 'Guest' , dob: '21-05-2003', gender: 'Male', height: '5.3ft', weight: '56', profileImage: '')));}),
                      buildMenuItem("Change Password",onTap: (){  Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => ChangePassword()));}),
                      buildMenuItem("Notification", enabled: false,onTap: (){  Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => Notification1()));}), // Disabled
                      buildMenuItem("Favorite",onTap: (){  Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => Favorite()));}),
                      buildMenuItem("Integration",onTap: (){  Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => Integration()));}),
                      buildMenuItem("Personal Reward",onTap: (){  Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => FoodScanScreen()));}),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
            
                // More Button
                GestureDetector(
                  onTap: (){
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => MoreScreen()));
                  },
                  child: Container(height: 65,alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: buildMenuItem("More"),
                  ),
                ),
                const SizedBox(height: 12),
            
                // Logout Button
                Container(height: 65,alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: buildMenuItem("Log Out"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
