import 'package:flutter/material.dart';

class UploadSuccess extends StatelessWidget {
  const UploadSuccess({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 12),
          const SizedBox(width: 2),
          Text('已上传', style: TextStyle(color: Colors.green.shade600, fontSize: 10)),
        ],
      ),
    );
  }
}
