import 'package:flutter/material.dart';

class BarcodeDetailHeader extends StatelessWidget {
  final String foodName;
  final String servingSize;
   // This comes from backend (scanned food photo)
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const BarcodeDetailHeader({
    Key? key,
    required this.foodName,
    required this.servingSize,

    required this.onBack,
    required this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image




        // Top buttons (Back + Favorite)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor:  Color.fromRGBO(35, 34, 32, 1),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      servingSize,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Color.fromRGBO(35, 34, 32, 1),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.green),
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
}
