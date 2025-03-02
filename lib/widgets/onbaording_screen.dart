import 'package:flutter/material.dart';
import 'package:innerglow/screens/home_screen.dart';
import 'package:innerglow/screens/time_capsule.dart';
import 'package:innerglow/widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Future You Letters',
      'description': 'Write letters to your future self for reflection, growth, and motivation.',
      'image': 'lib/assets/images/pic1.png',
    },
    {
      'title': 'Choose When to Receive',
      'description': 'Select a future date when your letter will be delivered to you by email.',
      'image': 'lib/assets/images/pic2.png',
    },
    {
      'title': 'Start Your Journey',
      'description': 'Begin capturing your thoughts, goals, and aspirations for your future self.',
      'image': 'lib/assets/images/pic3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: onboardingData[index]['title']!,
                    description: onboardingData[index]['description']!,
                    image: onboardingData[index]['image']!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _totalPages,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF863668)
                              : const Color(0xFFD8BFD8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _totalPages - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Futureletters(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF863668),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage < _totalPages - 1 ? 'Next' : 'Get Started',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}