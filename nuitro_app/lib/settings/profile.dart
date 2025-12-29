import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nuitro/More/custom_back_button2.dart';
import 'package:nuitro/components/submit_button.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String dob;
  final String gender;
  final String height;
  final String weight;
  final String profileImage;

  const ProfilePage({
    Key? key,
    required this.name,
    required this.email,
    required this.dob,
    required this.gender,
    required this.height,
    required this.weight,
    required this.profileImage,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children:[Text(label,style: GoogleFonts.manrope(fontWeight: FontWeight.w400,fontSize: 17),),
        SizedBox(height: 4,),
        TextField(
        controller: controller,

        decoration: InputDecoration(

          border: OutlineInputBorder(borderRadius:BorderRadius.circular(18)),
        ),
      ),
   ] );
  }

  Widget buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    final safeValue = items.contains(value) ? value : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(label),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: safeValue,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
      SafeArea(child: CustomElevatedButton(text: 'Save', onPressed: (){

      })),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomBackButton2(label:'My Profile' ,),
              // Profile Picture with edit button
              Stack(
                alignment: Alignment.center,
                children: [
                  // Profile image (bigger, circular)
                  ClipOval(
                    child: Image.asset(
                      'assets/images/profilephoto.png',
                      width: 110,   // ⬅️ increase size here
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Camera button
                  Positioned(
                    bottom: 35, // ⬅️ move slightly inside
                    right: 20,

                    child: GestureDetector(
                      onTap: () {
                        // TODO: implement image picker
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
,
              const SizedBox(height: 24),

              // Name
                 buildTextField("Name", nameController),
                 const SizedBox(height: 16),

              // Email
              buildTextField("Email", emailController),
              const SizedBox(height: 16),

              // DOB + Gender
              Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  SizedBox(width: (MediaQuery.of(context).size.width / 2) - 24,
                      child: buildDropdownField("DOB", widget.dob, ["21-05-2003", "01-01-2000"], (val) {})),
                  SizedBox(width: (MediaQuery.of(context).size.width / 2) - 24,
                      child: buildDropdownField("Gender", widget.gender, ["Male", "Female"], (val) {})),
                  SizedBox(width: (MediaQuery.of(context).size.width / 2) - 24,
                      child: buildDropdownField("Height", widget.height, ["5.3ft", "5.5ft", "6ft"], (val) {})),
                  SizedBox(width: (MediaQuery.of(context).size.width / 2) - 24,
                      child: buildDropdownField("Weight", widget.weight, ["56kg", "60kg", "70kg"], (val) {})),
                ],
              )

,


              // Height + Weight




              // Save Button

            ],
          ),
        ),
      ),
    );
  }
}
