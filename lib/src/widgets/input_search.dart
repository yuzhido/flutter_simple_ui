import 'package:flutter/material.dart';

// 输入搜索组件
class InputSearch extends StatefulWidget {
  final bool remote;
  final bool isLoading;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? remoteFetch;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final String? hintText;
  final bool showClearButton;

  const InputSearch({
    super.key,
    this.remote = false,
    this.isLoading = false,
    this.onChanged,
    this.onSubmitted,
    this.remoteFetch,
    this.onClear,
    this.controller,
    this.hintText,
    this.showClearButton = true,
  });

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
  }

  FocusNode focusNode = FocusNode();
  @override
  void dispose() {
    // 只有当controller是内部创建的时候才dispose
    if (widget.controller == null) {
      _searchController.dispose();
    }
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                focusNode: focusNode,
                onTapOutside: (e) => {focusNode.unfocus()},
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? (widget.remote ? '请输入关键字搜索' : '请输入关键字筛选'),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  // 设置所有状态的边框颜色
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFeeeeee), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFeeeeee), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFF007AFF), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                  suffixIcon: widget.showClearButton && _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            widget.onClear?.call();
                            widget.onChanged?.call('');
                          },
                          icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                          tooltip: '清除搜索',
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {}); // 更新suffixIcon显示状态
                  widget.onChanged?.call(value);
                },
                onSubmitted: (value) {
                  widget.onSubmitted?.call(value);
                },
              ),
            ),
          ),
          if (widget.remote)
            SizedBox(
              height: 45,
              child: ElevatedButton.icon(
                onPressed: widget.isLoading ? null : widget.remoteFetch,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  backgroundColor: widget.isLoading ? Colors.grey[300] : const Color(0xFF007AFF),
                  foregroundColor: widget.isLoading ? Colors.grey[500] : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: widget.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)))
                    : const Icon(Icons.search, size: 18),
                label: Text(widget.isLoading ? '搜索中...' : '搜索', style: const TextStyle(fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }
}
