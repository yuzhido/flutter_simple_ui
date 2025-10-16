import 'package:flutter/material.dart';

// 表单项标签信息
class LabelInfo extends StatefulWidget {
  final String? labelText;
  final bool? required;
  const LabelInfo(this.labelText, this.required, {super.key});
  @override
  State<LabelInfo> createState() => _LabelInfoState();
}

class _LabelInfoState extends State<LabelInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: widget.labelText ?? '未设置标签',
                  style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                  children: widget.required == true
                      ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
