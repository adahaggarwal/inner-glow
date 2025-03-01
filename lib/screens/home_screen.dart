import 'package:flutter/material.dart';
import 'package:innerglow/constants/colors.dart';
import 'package:innerglow/screens/chatbot/chatbot.dart';
import 'package:innerglow/screens/sleep_crisis_mode.dart';
import 'package:innerglow/widgets/features.dart';
import 'package:innerglow/widgets/features2.dart';
import 'package:innerglow/widgets/head_text.dart';

class HomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Headtext(text: "Good Morning,", color: textcol,),
              Headtext(text: "Adah", fontWeight: FontWeight.w700,),
              SizedBox(height: 20,),
              Headtext(text: "What’s one word to describe how you’re feeling?"),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset("lib/assets/images/excited.png", width: 160,),
                      Headtext(text: "Excited")
        
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset("lib/assets/images/lonely.png", width: 160,),
                      Headtext(text: "Lonely")
        
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset("lib/assets/images/relaxed.png", width: 160,),
                      Headtext(text: "Relaxed")
        
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset("lib/assets/images/stressed.png", width: 160,),
                      Headtext(text: "Stressed")
        
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Headtext(text: "Ready to begin ! Explore"),
              SizedBox(height: 20,),

              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Chatbot()));
                },
                child: Features(title: "Lumora", 
                description: "Your emotions, your voice—reflected back to you.", 
                imagePath: "lib/assets/images/innerecho.png",
                ),
              ),
              SizedBox(height: 20,),

              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SleepCrisisScreen()));
                },
                child: Features2(title: "Deep Rest", 
                description: "Instant support for nightime anxiety and insomnia.🌙", 
                imagePath: "lib/assets/images/deeprest.png",
                ),
              ),
              SizedBox(height: 20,),

              Features(title: "Self-Care tasks", 
              description: "Small, actionable self-care tasks with rewards.🎯 ", 
              imagePath: "lib/assets/images/selfcare.png",
              ),
              SizedBox(height: 20,),

              Features2(title: "Bloom Buddy", 
              description: "Complete your self-care tasks and nurture your plant as it flourishes with you. 🌱", 
              imagePath: "lib/assets/images/bloombuddy.png",
              ),
              SizedBox(height: 20,),

              Features(title: "Safe Haven", 
              description: "A customizable virtual relaxation room.🏡 ", 
              imagePath: "lib/assets/images/safe.png",
              ),
              SizedBox(height: 20,),

              Features2(title: "Time Capsule", 
              description: "Write letters to themselves, delivered later for self-reflection.📜", 
              imagePath: "lib/assets/images/tiny.png",
              ),
              SizedBox(height: 20,),

              Features(title: "Inner Track", 
              description: "Track progress and mood trends. 📊", 
              imagePath: "lib/assets/images/inner.png",
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
}