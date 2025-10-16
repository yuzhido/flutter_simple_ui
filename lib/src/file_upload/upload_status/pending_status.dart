import 'package:flutter/material.dart';

class PendingStatus extends StatelessWidget {
  const PendingStatus({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: Colors.orange.shade600, size: 12),
          const SizedBox(width: 2),
          Text('待上传', style: TextStyle(color: Colors.orange.shade600, fontSize: 10)),
        ],
      ),
    );
  }
}
