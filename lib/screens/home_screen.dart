import 'package:flutter/material.dart';
import 'package:innerglow/constants/colors.dart';
import 'package:innerglow/screens/bloombuddy.dart';
import 'package:innerglow/screens/chatbot/chatbot.dart';
import 'package:innerglow/screens/self_care_tasks_screen.dart';
import 'package:innerglow/screens/sleep_crisis_mode.dart';
import 'package:innerglow/screens/time_capsule.dart';
import 'package:innerglow/widgets/features.dart';
import 'package:innerglow/widgets/features2.dart';
import 'package:innerglow/widgets/head_text.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 10), // Added space before the logo
          child: Image.asset(
            'lib/assets/images/logo.png',
            width: 15, // Reduced size
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // Mood section with card
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
                        _buildMoodOption(
                          "lib/assets/images/excited.png", 
                          "Excited",
                          context,
                        ),
                        _buildMoodOption(
                          "lib/assets/images/lonely.png", 
                          "Lonely",
                          context,
                        ),
                        _buildMoodOption(
                          "lib/assets/images/relaxed.png", 
                          "Relaxed",
                          context,
                        ),
                        _buildMoodOption(
                          "lib/assets/images/stressed.png", 
                          "Stressed",
                          context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Headtext(
                    text: "Ready to begin! Explore", 
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 15),
              
              // Features section
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Chatbot()));
                },
                child: Features(
                  title: "Lumora",
                  description: "Your emotions, your voice—reflected back to you.",
                  imagePath: "lib/assets/images/innerecho.png",
                ),
              ),
              
              SizedBox(height: 15),
              
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SleepCrisisScreen()));
                },
                child: Features2(
                  title: "Deep Rest",
                  description: "Instant support for nightime anxiety and insomnia.🌙",
                  imagePath: "lib/assets/images/deeprest.png",
                ),
              ),
              
              SizedBox(height: 15),
              
              GestureDetector(   
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SelfCareTasksScreen()));
                },             
                child: Features(
                  title: "Self-Care tasks",
                  description: "Small, actionable self-care tasks with rewards.🎯",
                  imagePath: "lib/assets/images/selfcare.png",
                ),
              ),
              
              SizedBox(height: 15),
              
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BloomBuddy(completedTasks: 0)));
                },
                child: Features2(
                  title: "Bloom Buddy",
                  description: "Complete your self-care tasks and nurture your plant as it flourishes with you. 🌱",
                  imagePath: "lib/assets/images/bloombuddy.png",
                ),
              ),
              
              SizedBox(height: 15),
              
              Features(
                title: "Safe Haven",
                description: "A customizable virtual relaxation room.🏡",
                imagePath: "lib/assets/images/safe.png",
              ),
              
              SizedBox(height: 15),
              
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TimeCapsule()));
                }, 
                child: Features2(
                  title: "Time Capsule",
                  description: "Write letters to themselves, delivered later for self-reflection.📜",
                  imagePath: "lib/assets/images/tiny.png",
                ),
              ),
              
              SizedBox(height: 15),
              
              Features(
                title: "Inner Track",
                description: "Track progress and mood trends. 📊",
                imagePath: "lib/assets/images/inner.png",
              ),
              
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Wellness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodOption(String imagePath, String mood, BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 80),
            SizedBox(height: 10),
            Text(
              mood,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}