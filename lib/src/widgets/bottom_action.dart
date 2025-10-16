import 'package:flutter/material.dart';

class BottomAction extends StatelessWidget {
  final List<dynamic> selectedValues;
  final VoidCallback? onLookChosen;
  final VoidCallback? onSureChosen;
  const BottomAction({super.key, required this.selectedValues, this.onLookChosen, this.onSureChosen});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          // 左侧：已选择按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: selectedValues.isEmpty
                  ? null
                  : () {
                      onLookChosen?.call();
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                side: BorderSide(color: selectedValues.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF), width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.check_circle_outline, size: 18, color: selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF)),
              label: Text(
                '已选择 (${selectedValues.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 右侧：确认选择按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: selectedValues.isEmpty
                  ? null
                  : () {
                      onSureChosen?.call();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedValues.isEmpty ? Colors.grey[200] : const Color(0xFF007AFF),
                foregroundColor: selectedValues.isEmpty ? Colors.grey[500] : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              icon: Icon(Icons.check, size: 18, color: selectedValues.isEmpty ? Colors.grey[500] : Colors.white),
              label: Text(
                '确认选择',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: selectedValues.isEmpty ? Colors.grey[500] : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
