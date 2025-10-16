import 'package:flutter/material.dart';

class UploadFailed extends StatelessWidget {
  const UploadFailed({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: 12),
          const SizedBox(width: 2),
          Text('失败', style: TextStyle(color: Colors.red.shade600, fontSize: 10)),
        ],
      ),
    );
  }
}
