import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';

/// 下拉选择-查看已选择数据弹窗组件
class LookChosen<T> extends StatelessWidget {
  final List<SelectData<T>> selectedItems;
  final void Function(SelectData<T> item)? onRemoveItem;
  final VoidCallback? onClose;

  const LookChosen({super.key, required this.selectedItems, this.onRemoveItem, this.onClose});

  /// 显示已选择数据的弹窗
  static void show<T>({required BuildContext context, required List<SelectData<T>> selectedItems, required void Function(List<SelectData<T>> updated) onSelectedItemsChanged}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              title: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF007AFF), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '已选择的项目',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                          ),
                          Text('共 ${selectedItems.length} 项', style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: selectedItems.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              '暂未选择任何项目',
                              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            const Text('请返回选择一些项目', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: const Color(0xFFE9ECEF)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.check_circle, color: Color(0xFF007AFF), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                                      ),
                                      if (item.value != null) Text('值: ${item.value}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                                    ],
                                  ),
                                ),
                                // 移除按钮
                                Container(
                                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                                  child: IconButton(
                                    onPressed: () {
                                      selectedItems.removeWhere((selected) => selected.value == item.value);
                                      onSelectedItemsChanged(selectedItems);
                                      dialogSetState(() {});
                                    },
                                    icon: Icon(Icons.remove_circle_outline, color: Colors.red[400], size: 20),
                                    tooltip: '移除',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: selectedItems.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                              side: BorderSide(color: selectedItems.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF), width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('关闭', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: selectedItems.isEmpty ? null : () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedItems.isEmpty ? Colors.grey[200] : const Color(0xFF007AFF),
                              foregroundColor: selectedItems.isEmpty ? Colors.grey[500] : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            child: const Text('确认', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
