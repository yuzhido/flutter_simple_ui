import 'package:flutter/material.dart';

// 校验失败的信息
class ErrorInfo extends StatelessWidget {
  final String? errorText;
  const ErrorInfo(this.errorText, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(errorText ?? '校验失败，请检查输入', style: TextStyle(color: Colors.red, fontSize: 12));
  }
}
