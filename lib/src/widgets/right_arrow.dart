import 'package:flutter/material.dart';

class RightArrow extends StatelessWidget {
  final bool isChoosing;
  const RightArrow({super.key, this.isChoosing = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Icon(isChoosing ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: Colors.grey[600], size: 20),
    );
  }
}
