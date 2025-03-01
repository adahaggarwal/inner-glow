import 'package:flutter/material.dart';
import 'package:innerglow/constants/colors.dart';
import 'package:innerglow/widgets/head_text.dart';

class Features2 extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const Features2({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bg,
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 80,
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Headtext(
                  text: title,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 5), // Space between title and description
                Headtext(
                  text: description,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
