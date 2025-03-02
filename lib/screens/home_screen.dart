import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:innerglow/constants/colors.dart';
import 'package:innerglow/screens/bloombuddy.dart';
import 'package:innerglow/screens/chatbot/chatbot.dart';
import 'package:innerglow/screens/customisable_room.dart';
import 'package:innerglow/screens/self_care_tasks_screen.dart';
import 'package:innerglow/screens/sleep_crisis_mode.dart';
import 'package:innerglow/screens/time_capsule.dart';
import 'package:innerglow/widgets/features.dart';
import 'package:innerglow/widgets/features2.dart';
import 'package:innerglow/widgets/head_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;
  int _selectedIndex = 0; // Track the currently selected tab
  String? _selectedMood; // Track the selected mood

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the Chatbot screen when the "Chat" tab is selected
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Chatbot()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Image.asset(
            'lib/assets/images/logo.png',
            width: 15,
            height: 15,
          ),
        ),
        title: Text(
          "InnerGlow",
          style: TextStyle(
            color: textcol,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: textcol),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textcol),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Headtext(
                        text: "Good Morning,",
                        color: bg,
                        fontSize: 22,
                      ),
                      Headtext(
                        text: "Adah",
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Headtext(
                      text: "What's one word to describe how you're feeling?",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildMoodOption("lib/assets/images/excited.png", "Excited"),
                        _buildMoodOption("lib/assets/images/lonely.png", "Lonely"),
                        _buildMoodOption("lib/assets/images/relaxed.png", "Relaxed"),
                        _buildMoodOption("lib/assets/images/stressed.png", "Stressed"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              if (_selectedMood != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "You're feeling $_selectedMood today. Let's work on that!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bg,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(height: 20),

              Headtext(
                text: "Ready to begin! Explore",
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              _buildFeature("Lumora", "Your emotions, your voice—reflected back to you.", "lib/assets/images/innerecho.png", Chatbot()),
              SizedBox(height: 10),
              _buildFeature("Deep Rest", "Instant support for nightime anxiety and insomnia.🌙", "lib/assets/images/deeprest.png", SleepCrisisScreen(), isFeature2: true),
              SizedBox(height: 10),
              _buildFeature("Self-Care tasks", "Small, actionable self-care tasks with rewards.🎯", "lib/assets/images/selfcare.png", SelfCareTasksScreen()),
              SizedBox(height: 10),
              _buildFeature("Bloom Buddy", "Complete your self-care tasks and nurture your plant. 🌱", "lib/assets/images/bloombuddy.png", BloomBuddy(completedTasks: 0), isFeature2: true),
              SizedBox(height: 10),
              _buildFeature("Safe Haven", "A customizable virtual relaxation room.🏡", "lib/assets/images/safe.png", RoomCustomizerScreen()),
              SizedBox(height: 10),
              _buildFeature("Time Capsule", "Write letters to yourself, delivered later for self-reflection.📜", "lib/assets/images/tiny.png", TimeCapsule(), isFeature2: true),
              SizedBox(height: 10),
              _buildFeature("Inner Track", "Track progress and mood trends. 📊", "lib/assets/images/inner.png", null),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: bg,
        unselectedItemColor: Colors.black.withOpacity(0.4),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tab selection
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: 'Wellness'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMoodOption(String imagePath, String mood) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedMood == mood ? bg.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _selectedMood == mood ? bg : Colors.grey.withOpacity(0.2),
            width: _selectedMood == mood ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 80),
            SizedBox(height: 10),
            Text(mood, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description, String imagePath, Widget? screen, {bool isFeature2 = false}) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        }
      },
      child: isFeature2
          ? Features2(title: title, description: description, imagePath: imagePath)
          : Features(title: title, description: description, imagePath: imagePath),
    );
  }
}