import 'package:flutter/material.dart';

/// 级联数据节点（一级/二级/三级通用）
class CascadingItem<T> {
  final String label;
  final dynamic value;
  final T? extra;
  final List<CascadingItem<T>> children;

  const CascadingItem({required this.label, required this.value, this.extra, this.children = const []});

  @override
  bool operator ==(Object other) => identical(this, other) || other is CascadingItem && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// 三级级联多选组件
class CascadingSelect<T> extends StatefulWidget {
  /// 一级 -> 二级 -> 三级的数据
  final List<CascadingItem<T>> options;

  /// 顶部标题
  final String title;

  /// 选择模式：true=多选模式（第三级多选），false=单级模式（每级单选，不自动选中下级）
  final bool multiple;

  /// 是否展示第三级顶部的「不限」项（与具体选项互斥，仅多选模式有效）
  final bool showUnlimited;

  /// 默认选中的第三级 value 列表（仅多选模式有效）
  final List<dynamic>? defaultSelectedValues;

  /// 点击完成回调
  /// 多选模式：返回所有选中的第三级项
  /// 单级模式：返回当前选中的路径 [一级, 二级, 三级]
  final void Function(List<CascadingItem<T>> selected)? onConfirm;

  const CascadingSelect({super.key, required this.options, this.title = '三级联选多选', this.multiple = true, this.showUnlimited = true, this.defaultSelectedValues, this.onConfirm});

  @override
  State<CascadingSelect<T>> createState() => _CascadingSelectState<T>();
}

class _CascadingSelectState<T> extends State<CascadingSelect<T>> {
  // 外部展示/真实提交的选择值集合（仅第三级的 value，多选模式使用）
  final Set<dynamic> _selectedValues = <dynamic>{};

  // 弹窗里的临时状态
  late Set<dynamic> _tempSelectedValues;

  // 记录每个二级是否选中「不限」（key 为二级 value，多选模式使用）
  final Map<dynamic, bool> _unlimitedBySecond = <dynamic, bool>{};
  late Map<dynamic, bool> _tempUnlimitedBySecond;

  // 当前激活的一级/二级索引
  int _activeFirstIndex = 0;
  int _activeSecondIndex = 0;

  // 单级模式下的选择路径
  CascadingItem<T>? _selectedFirst;
  CascadingItem<T>? _selectedSecond;
  CascadingItem<T>? _selectedThird;

  @override
  void initState() {
    super.initState();
    if (widget.multiple) {
      if (widget.defaultSelectedValues != null) {
        _selectedValues.addAll(widget.defaultSelectedValues!);
      }
      _tempSelectedValues = Set<dynamic>.from(_selectedValues);
      _tempUnlimitedBySecond = Map<dynamic, bool>.from(_unlimitedBySecond);
    }
  }

  List<CascadingItem<T>> get _firstList => widget.options;
  List<CascadingItem<T>> get _secondList => _firstList.isEmpty ? const [] : _firstList[_activeFirstIndex.clamp(0, _firstList.length - 1)].children;
  List<CascadingItem<T>> get _thirdList => _secondList.isEmpty ? const [] : _secondList[_activeSecondIndex.clamp(0, _secondList.length - 1)].children;

  // 打开选择面板
  void _openSheet() {
    if (widget.multiple) {
      _tempSelectedValues = Set<dynamic>.from(_selectedValues);
      _tempUnlimitedBySecond = Map<dynamic, bool>.from(_unlimitedBySecond);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void setStateModal(VoidCallback fn) => setModalState(fn);
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  // 头部：取消 / 标题 / 完成
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text('取消', style: TextStyle(color: Color(0xFF666666), fontSize: 16)),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.multiple) {
                              setState(() {
                                _selectedValues
                                  ..clear()
                                  ..addAll(_tempSelectedValues);
                                _unlimitedBySecond
                                  ..clear()
                                  ..addAll(_tempUnlimitedBySecond);
                              });
                              final selected = _collectSelectedItems();
                              widget.onConfirm?.call(selected);
                            } else {
                              final selected = _collectSinglePath();
                              widget.onConfirm?.call(selected);
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('完成', style: TextStyle(color: Color(0xFF007AFF), fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  // 三列（支持左右滑动）
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: 110, child: _buildFirstList(setStateModal)),
                          SizedBox(width: 140, child: _buildSecondList(setStateModal)),
                          SizedBox(width: 200, child: _buildThirdList(setStateModal)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 一级列表
  Widget _buildFirstList(void Function(VoidCallback fn) setStateModal) {
    return Container(
      color: const Color(0xFFF7F7F7),
      child: ListView.builder(
        itemCount: _firstList.length,
        itemBuilder: (context, index) {
          final item = _firstList[index];
          final bool active = widget.multiple ? index == _activeFirstIndex : _selectedFirst?.value == item.value;
          return InkWell(
            onTap: () {
              setStateModal(() {
                if (widget.multiple) {
                  _activeFirstIndex = index;
                  _activeSecondIndex = 0;
                } else {
                  _selectedFirst = item;
                  _selectedSecond = null;
                  _selectedThird = null;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              color: active ? const Color(0xFFEFEFEF) : Colors.transparent,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: active ? const Color(0xFF007AFF) : const Color(0xFF333333), fontSize: 14, fontWeight: active ? FontWeight.w600 : FontWeight.normal),
              ),
            ),
          );
        },
      ),
    );
  }

  // 二级列表
  Widget _buildSecondList(void Function(VoidCallback fn) setStateModal) {
    final list = widget.multiple ? _secondList : (_selectedFirst?.children ?? []);
    return Container(
      color: const Color(0xFFFDFDFD),
      child: list.isEmpty
          ? const Center(child: Text('无二级'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final bool active = widget.multiple ? index == _activeSecondIndex : _selectedSecond?.value == item.value;
                final secondValue = item.value;
                final bool selectedSome = widget.multiple ? _isSecondSelected(secondValue) : false;
                return InkWell(
                  onTap: () {
                    setStateModal(() {
                      if (widget.multiple) {
                        _activeSecondIndex = index;
                      } else {
                        _selectedSecond = item;
                        _selectedThird = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    color: active ? const Color(0xFFF2F6FF) : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: active ? const Color(0xFF007AFF) : const Color(0xFF333333),
                              fontSize: 14,
                              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (selectedSome)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 三级列表
  Widget _buildThirdList(void Function(VoidCallback fn) setStateModal) {
    final list = widget.multiple ? _thirdList : (_selectedSecond?.children ?? []);

    if (!widget.multiple) {
      // 单级模式：单选列表
      return Container(
        color: Colors.white,
        child: list.isEmpty
            ? const Center(child: Text('无三级'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    title: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Radio<dynamic>(
                      value: item.value,
                      groupValue: _selectedThird?.value,
                      onChanged: (val) {
                        setStateModal(() {
                          _selectedThird = item;
                        });
                      },
                      activeColor: const Color(0xFF007AFF),
                    ),
                    onTap: () {
                      setStateModal(() {
                        _selectedThird = item;
                      });
                    },
                  );
                },
              ),
      );
    }

    // 多选模式：多选 + 不限
    return Container(
      color: Colors.white,
      child: list.isEmpty
          ? const Center(child: Text('无三级'))
          : ListView.builder(
              itemCount: list.length + (widget.showUnlimited ? 1 : 0),
              itemBuilder: (context, index) {
                // 顶部「不限」
                if (widget.showUnlimited && index == 0) {
                  final second = _secondList.isEmpty ? null : _secondList[_activeSecondIndex];
                  final secondValue = second?.value;
                  final bool isUnlimited = _tempUnlimitedBySecond[secondValue] == true;
                  return ListTile(
                    title: const Text('不限'),
                    trailing: Icon(isUnlimited ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isUnlimited ? const Color(0xFF007AFF) : Colors.grey[400]),
                    onTap: () {
                      setStateModal(() {
                        final thirdValuesOfSecond = list.map((e) => e.value).toSet();
                        _tempSelectedValues.removeAll(thirdValuesOfSecond);
                        _tempUnlimitedBySecond[secondValue] = true;
                      });
                    },
                  );
                }

                final realIndex = widget.showUnlimited ? index - 1 : index;
                final item = list[realIndex];
                final bool checked = _tempSelectedValues.contains(item.value);
                final second = _secondList.isEmpty ? null : _secondList[_activeSecondIndex];
                final secondValue = second?.value;
                final bool isUnlimited = _tempUnlimitedBySecond[secondValue] == true;
                return ListTile(
                  title: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Checkbox(
                    value: checked,
                    onChanged: (val) {
                      setStateModal(() {
                        if (val == true) {
                          _tempSelectedValues.add(item.value);
                          if (secondValue != null) _tempUnlimitedBySecond[secondValue] = false;
                        } else {
                          _tempSelectedValues.remove(item.value);
                        }
                      });
                    },
                    activeColor: const Color(0xFF007AFF),
                  ),
                  enabled: widget.multiple,
                  onTap: () {
                    setStateModal(() {
                      final bool newVal = !_tempSelectedValues.contains(item.value);
                      if (newVal) {
                        _tempSelectedValues.add(item.value);
                        if (secondValue != null) _tempUnlimitedBySecond[secondValue] = false;
                      } else {
                        _tempSelectedValues.remove(item.value);
                      }
                    });
                  },
                  subtitle: isUnlimited ? const Text('已选择不限', style: TextStyle(color: Colors.grey, fontSize: 12)) : null,
                );
              },
            ),
    );
  }

  bool _isSecondSelected(dynamic secondValue) {
    if (_tempUnlimitedBySecond[secondValue] == true) return true;
    final children = _secondList
        .firstWhere(
          (s) => s.value == secondValue,
          orElse: () => const CascadingItem(label: '', value: '', children: []),
        )
        .children
        .map((e) => e.value)
        .toSet();
    return _tempSelectedValues.any((val) => children.contains(val));
  }

  List<CascadingItem<T>> _collectSelectedItems() {
    final List<CascadingItem<T>> result = [];
    for (final first in widget.options) {
      for (final second in first.children) {
        for (final third in second.children) {
          if (_selectedValues.contains(third.value)) {
            result.add(third);
          }
        }
      }
    }
    return result;
  }

  List<CascadingItem<T>> _collectSinglePath() {
    final List<CascadingItem<T>> result = [];
    if (_selectedFirst != null) result.add(_selectedFirst!);
    if (_selectedSecond != null) result.add(_selectedSecond!);
    if (_selectedThird != null) result.add(_selectedThird!);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(child: _buildDisplayText()),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayText() {
    if (widget.multiple) {
      // 多选模式：显示选中的第三级项
      return _selectedValues.isEmpty
          ? const Text('请选择', style: TextStyle(color: Color(0xFF999999), fontSize: 16))
          : SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedValues.length,
                separatorBuilder: (context, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final value = _selectedValues.elementAt(index);
                  final label = _findLabelByValue(value) ?? value.toString();
                  return Container(
                    alignment: const Alignment(0, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF007AFF)),
                    ),
                    child: Text(label, style: const TextStyle(color: Color(0xFF007AFF), fontSize: 14)),
                  );
                },
              ),
            );
    } else {
      // 单级模式：显示选择路径
      final path = <String>[];
      if (_selectedFirst != null) path.add(_selectedFirst!.label);
      if (_selectedSecond != null) path.add(_selectedSecond!.label);
      if (_selectedThird != null) path.add(_selectedThird!.label);

      return path.isEmpty
          ? const Text('请选择', style: TextStyle(color: Color(0xFF999999), fontSize: 16))
          : Text(
              path.join(' / '),
              style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
              overflow: TextOverflow.ellipsis,
            );
    }
  }

  String? _findLabelByValue(dynamic value) {
    for (final first in widget.options) {
      for (final second in first.children) {
        for (final third in second.children) {
          if (third.value == value) return third.label;
        }
      }
    }
    return null;
  }
}
