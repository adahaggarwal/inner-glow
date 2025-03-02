import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for image
          Container(
            padding: EdgeInsets.all(10),
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              image, // Use the 'image' property passed to the OnboardingPage widget
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
                      ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}