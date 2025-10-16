import 'package:flutter/material.dart';

class LoadingData extends StatelessWidget {
  const LoadingData({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)), strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            '正在搜索中...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('正在为您搜索相关数据', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
        ],
      ),
    );
  }
}
