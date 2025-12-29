import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../More/custom_back_button2.dart';

class Integration extends StatefulWidget {
  const Integration({super.key});

  @override
  State<Integration> createState() => _IntegrationState();
}

class _IntegrationState extends State<Integration> {
  bool showApps = true;
  final green =Color.fromRGBO(220, 250, 157, 1);// toggle between tabs

  // Example apps
  final List<Map<String, dynamic>> apps = [
    {
      "name": "Apple Health",
      "icon": Icons.favorite,
      "connected": true,
      "enabled": true,
    },
    {
      "name": "Google Fit",
      "icon": Icons.fitness_center,
      "connected": true,
      "enabled": true,
    },
    {
      "name": "GARMIN",
      "icon": Icons.watch,
      "connected": false,
      "enabled": false,
    },
    {
      "name": "fitbit",
      "icon": Icons.directions_run,
      "connected": false,
      "enabled": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CustomBackButton2(label:'Integration',),
              // Tabs
              SizedBox(height: 15,),
              Container(
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => showApps = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: showApps ? green : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child:  Text(
                              "Apps",
                              style: GoogleFonts.manrope(fontSize:17,fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => showApps = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: !showApps ? green : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child:  Text(
                              "Overview",
                              style: GoogleFonts.manrope(fontSize:17,fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          SizedBox(height: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 5),
                  child: showApps
                      ? _buildAppsPage()        // Apps stays scrollable (fills space)
                      : SingleChildScrollView(  // Overview wraps content but allows scroll if needed
                    child: _buildOverviewPage(),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Apps tab
  Widget _buildAppsPage() {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return Container(

          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(padding: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Icon(app["icon"], color: Colors.red),
              title: Text(app["name"]),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    app["connected"] = !app["connected"];
                    app["enabled"] = app["connected"];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: app["connected"] ? green : green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        app["connected"] ? "Connected" : "Connect",
                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      if (app["connected"])
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.check_circle, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  // Overview tab
  Widget _buildOverviewPage() {
    final connectedApps = apps.where((app) => app["connected"]).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 👈 makes column wrap its children
        children: connectedApps.map((app) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(app["name"]),
                Switch(
                  value: app["enabled"],
                  thumbColor: MaterialStateProperty.all(Colors.white),
                  activeTrackColor: green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[600],
                  onChanged: (val) {
                    setState(() {
                      app["enabled"] = val;
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }


}
