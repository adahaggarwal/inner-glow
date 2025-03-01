import 'package:flutter/material.dart';

class Headtext extends StatelessWidget{
  final String text;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;
  final String ?fontFamily;
 
  
  Headtext({
    Key? key,
    required this.text,
    this.color = Colors.black,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 20.0,
    this.fontFamily 
  
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
 
    return Text(text, 
    textAlign: TextAlign.center,
    style: TextStyle(
      color: color,
      
      fontWeight: fontWeight,
      fontSize: fontSize,
      fontFamily: fontFamily,
      
    ),
    );
  }
}