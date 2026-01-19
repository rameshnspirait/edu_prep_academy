import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;

  const AppText(
    this.text, {
    super.key,
    required this.style,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: align);
  }
}
