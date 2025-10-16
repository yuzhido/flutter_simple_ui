import 'package:flutter/material.dart';

class UploadingStatus extends StatelessWidget {
  final double progress;
  const UploadingStatus(this.progress, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, value: progress, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 4),
          Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.blue.shade600, fontSize: 10)),
        ],
      ),
    );
  }
}
