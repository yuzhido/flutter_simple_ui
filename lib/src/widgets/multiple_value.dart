import 'package:flutter/material.dart';

class MultipleValue extends StatelessWidget {
  // 选中的值列表
  final List<String> value;
  // 未选中的提示文字
  final String tips;
  // ignore: unnecessary_type_check
  const MultipleValue({super.key, this.value = const [], this.tips = '请选择(可多选)'}) : assert(!(value is! List<String>), '当multiple为true时，value必须是List<String>类型');
  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return Text(tips, style: const TextStyle(fontSize: 16, color: Color(0xFF999999)));
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: value.length,
        separatorBuilder: (context, idx) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final val = value[idx];
          return Container(
            alignment: Alignment(0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF007AFF)),
            ),
            child: Text(val, style: const TextStyle(fontSize: 15, color: Color(0xFF007AFF))),
          );
        },
      ),
    );
  }
}
