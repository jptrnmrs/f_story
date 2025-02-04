import 'package:class_f_story/_core/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomLogo extends StatelessWidget {
  final String title;

  const CustomLogo(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: xlargeGap,
        ),
        SvgPicture.asset(
          'assets/logo.svg',
          width: 70,
          height: 70,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: largeGap,
        ),
      ],
    );
  }
}
