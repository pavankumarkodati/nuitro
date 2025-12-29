import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSubmitButton extends StatefulWidget {
  final double progress;
  final VoidCallback onNext;   // new

  const ProfileSubmitButton({
    super.key,
    required this.progress,
    required this.onNext,
  });

  @override
  State<ProfileSubmitButton> createState() => _ProfileSubmitButtonState();
}

class _ProfileSubmitButtonState extends State<ProfileSubmitButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: widget.progress,
                    strokeWidth: 3,
                    color: Colors.black,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 67.5,
                  width: 67.5,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white),
                    onPressed: widget.onNext,  // trigger parent update
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
