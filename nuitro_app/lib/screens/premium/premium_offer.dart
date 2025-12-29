import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuitro/screens/premium/premium.dart';
class GoPremium extends StatelessWidget {
  const GoPremium({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Row(
                children: [ Spacer(),
                  // Back Button0
                  GestureDetector(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cancel_sharp,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),onTap: () {
                    Navigator.pop(context); // 👈 go back to previous page
                  },
                  ),

                  // Page Counter

                ],
              ),
              SizedBox(height: 30,),
              Text('One Time Offer',style: GoogleFonts.manrope(color:Colors.black,fontSize:28,fontWeight: FontWeight.bold ),),
              SizedBox(height: 10,),  Text('Unlock smarter nutrition with AI-powered tools',textAlign:TextAlign.center,style: GoogleFonts.manrope(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 17),),
              SizedBox(height: 60,) ,Image.asset('assets/images/premium.png')
              , Spacer() ,
              Container(width:double.infinity,decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:  Color.fromRGBO(220, 250, 157, 1),
              ),child:
              TextButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Premium()),
                );
              }, child: Text('GO With Premium',style:
              GoogleFonts.manrope(color: Colors.black,fontSize:18,fontWeight:
              FontWeight.w600),)),)
              ,TextButton(onPressed: (){}, child: Text("Skip",style:GoogleFonts.manrope(fontWeight:FontWeight.w600 ,fontSize: 18,color: Colors.grey),))
              ,   SizedBox(height: 20,), ],
          ),
        ),
      ), );
  }
}
