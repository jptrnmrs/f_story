import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;

  // 내장되어있는 데이터 타입
  final VoidCallback click;

  const CustomTextButton({required this.text, required this.click, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: click,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          decoration: TextDecoration.underline
        ),
      ),
    );
  }
}
