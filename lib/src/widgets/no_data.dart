import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final bool remote;
  const NoData({super.key, this.remote = false});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无数据', style: TextStyle(color: Color(0xFF666666), fontSize: 16)),
          const SizedBox(height: 8),
          Text(remote ? '请尝试其他关键词搜索' : '请尝试其他筛选条件', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
        ],
      ),
    );
  }
}
