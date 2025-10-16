import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/src/widgets/multiple_value.dart';
import 'package:flutter_simple_ui/src/widgets/single_value.dart';

// 选择组件
class ChooseContainer extends StatefulWidget {
  // 是否多选
  final bool? multiple;
  // 提示词占位符
  final String tips;
  // 选中的值
  final dynamic value;
  // 是否正在进行选择
  final bool isChoosing;
  // 选择组件
  final Function? onTap;
  const ChooseContainer({super.key, this.multiple = false, this.tips = '请选择选项', this.onTap, this.value, this.isChoosing = false});
  @override
  State<ChooseContainer> createState() => _DropdownContainerState();
}

class _DropdownContainerState extends State<ChooseContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 单选多选的值
            Expanded(
              child: widget.multiple == true ? MultipleValue(value: widget.value ?? [], tips: widget.tips) : SingleValue(value: widget.value ?? '', tips: widget.tips),
            ),
            // 提示小箭头
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Icon(widget.isChoosing ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
