import 'package:flutter/material.dart';

// 单选值显示
class SingleValue extends StatelessWidget {
  // 提示词占位符
  final String tips;
  // 单选的数据
  final String? value;
  const SingleValue({super.key, this.tips = '请选择(单选)', this.value});
  @override
  Widget build(BuildContext context) {
    return Text(
      (value != null && value != '') ? value! : tips,
      style: TextStyle(
        fontSize: 16,
        color: (value != null && value != '') ? const Color(0xFF333333) : const Color(0xFF999999),
        fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
