import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';
import 'package:flutter_simple_ui/src/widgets/is_expanded.dart';
import 'package:flutter_simple_ui/src/widgets/circle_loading.dart';

// 树结构选择组件每一项小组件
class TreeChooseItem<T> extends StatefulWidget {
  final SelectData<T>? data;
  final bool isSelected;
  final bool isLoading;
  final bool isExpanded;
  final bool multiple;
  final int level; // 新增：层级深度
  final bool hasChildren; // 新增：是否有子节点
  final ValueChanged<SelectData<T>?>? onTap;
  final VoidCallback? onExpandToggle; // 新增：展开/收起回调

  const TreeChooseItem({
    super.key,
    this.data,
    this.isSelected = false,
    this.isLoading = false,
    this.isExpanded = false,
    this.multiple = false,
    this.level = 0, // 默认层级为0
    this.hasChildren = false, // 默认无子节点
    this.onTap,
    this.onExpandToggle, // 展开回调
  });

  @override
  State<TreeChooseItem<T>> createState() => _TreeChooseItemState<T>();
}

class _TreeChooseItemState<T> extends State<TreeChooseItem<T>> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!(widget.data);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        padding: EdgeInsets.only(
          left: 8 + (widget.level * 20), // 根据层级添加左侧缩进
          right: 8,
          top: 14,
          bottom: 14,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.blue.shade50.withValues(alpha: 0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: widget.isSelected ? Border.all(color: Colors.blue.shade200) : Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // 左侧图标区域
            GestureDetector(
              onTap: widget.hasChildren ? widget.onExpandToggle : null, // 只有有子节点时才能点击
              child: SizedBox(
                width: 24,
                height: 24,
                child: widget.hasChildren ? (widget.isLoading ? CircleLoading() : IsExpanded(widget.isExpanded)) : null, // 没有子节点时不显示任何图标
              ),
            ),

            // 中间文本区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  widget.data?.label ?? '当前选中的节点',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            // 右侧选中图标区域（始终占位，确保高度一致）
            SizedBox(
              width: 24, // 固定宽度，确保布局一致
              height: 24, // 固定高度，确保布局一致
              child: widget.isSelected
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    )
                  : null, // 非选中状态为空，但仍占据空间
            ),
          ],
        ),
      ),
    );
  }
}
