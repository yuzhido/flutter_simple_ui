import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';

class DropdownContainer<T> extends StatefulWidget {
  // 是否多选
  final bool? multiple;
  // 提示词占位符
  final String tips;
  // 多选的数据
  final List<SelectData<T>>? items;
  // 单选的数据
  final SelectData<T>? item;
  // 是否正在进行选择
  final bool isChoosing;
  // 是否显示清除按钮
  final bool showClear;
  // 是否有选中项
  final bool hasSelection;
  // 点击清除按钮的回调
  final Function? onClear;

  const DropdownContainer({
    super.key,
    this.multiple = false,
    // 默认提示词
    this.tips = '请选择选项',
    this.items,
    this.item,
    this.isChoosing = false,
    this.onClear,
    this.showClear = false,
    this.hasSelection = false,
  });
  @override
  State<DropdownContainer<T>> createState() => _DropdownContainerState<T>();
}

class _DropdownContainerState<T> extends State<DropdownContainer<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: widget.multiple == true
                ? (widget.items?.isEmpty ?? true
                      ? Text(widget.tips, style: const TextStyle(fontSize: 16, color: Color(0xFF999999)))
                      : SizedBox(
                          height: 30,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.items?.length ?? 0,
                            separatorBuilder: (context, idx) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final val = widget.items?[idx];
                              return Container(
                                alignment: Alignment(0, 0),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF4FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF007AFF)),
                                ),
                                child: Text(val?.label ?? '', style: const TextStyle(fontSize: 15, color: Color(0xFF007AFF))),
                              );
                            },
                          ),
                        ))
                : Text(
                    widget.item?.label ?? (widget.tips),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.item != null ? const Color(0xFF333333) : const Color(0xFF999999),
                      fontWeight: widget.item != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (!widget.hasSelection || !widget.showClear)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Icon(widget.isChoosing ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: Colors.grey[600], size: 20),
            ),
          if (widget.hasSelection && widget.showClear)
            InkWell(
              onTap: () => widget.onClear?.call(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.close, color: Colors.grey[600], size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
