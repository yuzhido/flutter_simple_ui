import 'package:flutter/material.dart';

class OnAdd extends StatelessWidget {
  final Function(String)? onAdd;
  final String? kw;
  const OnAdd({super.key, this.onAdd, this.kw});
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600);
    return Container(
      margin: const EdgeInsets.only(top: 12, right: 12, left: 12, bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey[500], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                children: [
                  TextSpan(text: '没有查询到你想要的内容，'),
                  TextSpan(text: '去新增', style: textStyle),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              onAdd?.call(kw ?? '');
            },
            child: Text('去新增', style: textStyle),
          ),
        ],
      ),
    );
  }
}
