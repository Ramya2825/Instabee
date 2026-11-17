import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? backgroundColor;
  const new({super.key,required this.text,required this.onPressed , this.textColor , this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:  backgroundColor ?? Colors.blueAccent,
          borderRadius: BorderRadius.circular(8),
          
        ),
        child: Center(child: Text(text,style: TextStyle(color: textColor ?? Colors.white,fontWeight: FontWeight.bold),)),
      ),
    );
  }
}
