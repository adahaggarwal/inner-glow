import 'package:flutter/material.dart';

class WritingPromptCard extends StatelessWidget {
  final String prompt;
  final VoidCallback onTap;

  const WritingPromptCard({
    Key? key,
    required this.prompt,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6EF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8C5D9), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                prompt,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF863668),
            ),
          ],
        ),
      ),
    );
  }
}