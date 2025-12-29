import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodDetailHeader extends StatelessWidget {
  final String foodName;
  final String servingSize;
  final String imageUrl; // This comes from backend (scanned food photo)
  final String? capturedImagePath; // Local captured image path (optional)
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const FoodDetailHeader({
    Key? key,
    required this.foodName,
    required this.servingSize,
    required this.imageUrl,
    this.capturedImagePath,
    required this.onBack,
    required this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        SizedBox(
          height: 260,
          width: double.infinity,
          child: (capturedImagePath != null && capturedImagePath!.isNotEmpty)
              ? Image.file(
                  File(capturedImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _networkOrAssetFallback();
                  },
                )
              : _networkOrAssetFallback(),
        ),


        // Dark gradient overlay (optional for text readability)
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black54, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Top buttons (Back + Favorite)
        Padding(
padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Color.fromRGBO(35, 34, 32, 1),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: onBack,
                ),
              ),
              Expanded(
                child: Column(
                  children: [

                    SizedBox(width: 500,
                      child: Text(
                        foodName,
                        maxLines: 2, // ✅ Only 1 line
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      servingSize,
                      style: GoogleFonts.zenKakuGothicAntique(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Color.fromRGBO(35, 34, 32, 1),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: onFavorite,
                ),
              ),
            ],
          ),
        ),

        // Food title + serving size

      ],
    );
  }

  Widget _networkOrAssetFallback() {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/images/Food.png",
          fit: BoxFit.cover,
        );
      },
    );
  }
}
