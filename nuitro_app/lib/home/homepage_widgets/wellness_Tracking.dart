import 'package:flutter/material.dart';

class WellnessTrackingPage extends StatelessWidget {
  final String title;
  final String question;
  final List<String> options;
  final ValueChanged<String>? onOptionSelected;
  final String selected;
  final VoidCallback? onMenuTap;

  const WellnessTrackingPage({
    super.key,
    this.title = 'Wellness Tracking',
    required this.question,
    required this.options,
    this.selected = '',
    this.onOptionSelected,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    if (question.isEmpty || options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(245, 243, 120, 1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options
                    .map((label) => FeelingChip(
                          label: label,
                          isSelected: label == selected,
                          onTap: onOptionSelected,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeelingChip extends StatelessWidget {
  final String label;
  final ValueChanged<String>? onTap;
  final bool isSelected;

  const FeelingChip({super.key, required this.label, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(38, 50, 56, 1)
              : const Color.fromRGBO(221, 192, 255, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
