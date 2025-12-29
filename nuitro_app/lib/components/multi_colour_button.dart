import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class MultiColourButton extends StatelessWidget {
  final String leftButton;
  final String rightButton;
  final VoidCallback leftButtonTap;
  final VoidCallback rightButtonTap;
  final bool isLeftSelected;

  const MultiColourButton({
    Key? key,
    required this.leftButton,
    required this.rightButton,
    required this.leftButtonTap,
    required this.rightButtonTap,
    required this.isLeftSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black12, width: 1),
              bottom: BorderSide(color: Colors.black12, width: 1),
              left: BorderSide(color: Colors.black12, width: 1),
              right: BorderSide(color: Colors.black12, width: 1),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            color: isLeftSelected ?  Colors.white : Color.fromRGBO(145, 199, 136,1) ,
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            onPressed: leftButtonTap,
            child: Text(
              leftButton,
              style: TextStyle(color: isLeftSelected ? Colors.grey : Colors.white, fontSize: 15),
            ),
          ),
        ),
SizedBox(width: 1,),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black12, width: 1),
              bottom: BorderSide(color: Colors.black12, width: 1),
              right: BorderSide(color: Colors.black12, width: 1),
              left: BorderSide(color: Colors.black12, width: 1),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            color: isLeftSelected ?  const Color.fromRGBO(145, 199, 136,1):Colors.white ,
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            onPressed: rightButtonTap,
            child: Text(
              rightButton,
              style:  TextStyle( color: isLeftSelected ? Colors.white : Colors.grey, fontSize: 15),
            ),
          ),
        ),

      ],
    );
  }
}
