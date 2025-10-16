import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';

class ChooseItem<T> extends StatefulWidget {
  // 是否选中
  final bool isSelected;
  // 是否多选
  final bool multiple;
  // 数据项
  final SelectData<T> item;
  // 点击回调
  final Function(SelectData<T>)? onTap;
  const ChooseItem({super.key, this.isSelected = false, this.multiple = false, required this.item, this.onTap});
  @override
  State<ChooseItem<T>> createState() => _ChooseItemState<T>();
}

class _ChooseItemState<T> extends State<ChooseItem<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12, right: 12, left: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.isSelected ? const Color(0xFF007AFF) : Colors.grey[200]!),
        boxShadow: widget.isSelected
            ? [BoxShadow(color: const Color(0xFF007AFF).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        title: Text(
          widget.item.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
            color: widget.isSelected ? const Color(0xFF007AFF) : const Color(0xFF333333),
          ),
        ),
        leading: ChooseMode<SelectData<T>>(multiple: widget.multiple, isSelected: widget.isSelected, item: widget.item, onTap: (val) => widget.onTap),
        onTap: onChooseItem,
      ),
    );
  }

  // 点击选中
  onChooseItem() {
    if (widget.onTap != null) {
      widget.onTap!(widget.item);
    }
  }
}

// 选中模式-单选或者多选
class ChooseMode<T> extends StatefulWidget {
  final T item;
  // 选中模式-单选或者多选
  final bool multiple;
  final bool isSelected;
  final void Function(T)? onTap;

  const ChooseMode({super.key, required this.multiple, required this.isSelected, required this.item, this.onTap});
  @override
  State<ChooseMode<T>> createState() => _ChooseModeState<T>();
}

class _ChooseModeState<T> extends State<ChooseMode<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget.multiple == true) {
      return Checkbox(
        value: widget.isSelected,
        activeColor: const Color(0xFF007AFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (val) {
          if (widget.onTap != null) {
            widget.onTap!(widget.item);
          }
        },
      );
    }
    return Radio(
      value: widget.isSelected,
      groupValue: true,
      activeColor: const Color(0xFF007AFF),
      onChanged: (val) {
        if (widget.onTap != null) {
          widget.onTap!(widget.item);
        }
      },
    );
  }
}
