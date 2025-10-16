import 'package:flutter/material.dart';

class IsExpanded extends StatelessWidget {
  final bool isExpanded;
  const IsExpanded(this.isExpanded, {super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: isExpanded ? 0.25 : 0,
      duration: const Duration(milliseconds: 200),
      child: Icon(Icons.keyboard_arrow_right_rounded, size: 22, color: Colors.grey.shade600),
    );
  }
}
