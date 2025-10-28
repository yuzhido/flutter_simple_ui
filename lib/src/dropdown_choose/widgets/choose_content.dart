import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';
import 'package:flutter_simple_ui/src/dropdown_choose/widgets/choose_item.dart';
import 'package:flutter_simple_ui/src/widgets/header_title.dart';
import 'package:flutter_simple_ui/src/widgets/input_search.dart';
import 'package:flutter_simple_ui/src/widgets/loading_data.dart';
import 'package:flutter_simple_ui/src/widgets/no_data.dart';
import 'package:flutter_simple_ui/src/widgets/on_add.dart';
import 'package:flutter_simple_ui/src/dropdown_choose/widgets/look_chosen.dart';

class ChooseContent<T> extends StatefulWidget {
  // 是否可以过滤
  final bool filterable;
  // 是否开启远程搜索
  final bool remote;
  // 远程搜索方法-一个返回Future<List<SelectData<T>>>的函数
  final Future<List<SelectData<T>>> Function(String)? remoteSearch;
  // 是否总是刷新数据（仅在remote为true时有效）
  final bool alwaysRefresh;
  // 缓存更新回调-用于将搜索结果缓存到父组件
  final void Function(List<SelectData<T>>)? onCacheUpdate;
  // 是否显示新增按钮
  final bool showAdd;
  // 是否多选
  final bool multiple;
  // 新增回调
  final Future<bool?> Function(String)? onAdd;
  // 选中回调
  final void Function(SelectData<T>?, List<SelectData<T>>)? onSelected;
  // 默认展示的数据
  final List<SelectData<T>> options;
  // 占位符文本
  final String? tips;
  // 默认选中的数据 - 支持单个或多个
  final dynamic defaultValue; // SelectData<T> 或 List<SelectData<T>>
  const ChooseContent({
    super.key,
    this.filterable = false,
    this.remote = false,
    this.alwaysRefresh = false,
    this.showAdd = false,
    this.multiple = false,
    this.onAdd,
    this.onSelected,
    this.options = const [],
    this.defaultValue,
    this.tips,
    this.remoteSearch,
    this.onCacheUpdate,
  });
  @override
  State<ChooseContent<T>> createState() => _ChooseContentState<T>();
}

class _ChooseContentState<T> extends State<ChooseContent<T>> {
  // 是否正在加载数据（远程）
  bool _isLoading = false;
  // 过滤的列表
  List<SelectData<T>> _filteredList = [];
  // 当前选中的值
  SelectData<T>? _selectedValue;
  final List<SelectData<T>> _selectedValues = [];
  // 数据列表
  List<SelectData<T>> _dataList = [];
  // 搜索框控制器
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // 将options数据保存到_dataList中
    _dataList = List.from(widget.options);
    // 初始化过滤列表，用于展示数据
    _filteredList = List.from(_dataList);
    // 初始化默认选中值
    _initializeDefaultValue();
    // 如果是远程搜索且没有初始数据，自动加载
    _autoLoadRemoteDataIfNeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChooseContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当options发生变化时，重新初始化数据列表
    if (oldWidget.options != widget.options) {
      _dataList = List.from(widget.options);
      _filteredList = List.from(_dataList);
      // 重新初始化默认选中值
      _initializeDefaultValue();
    }
  }

  // 初始化默认值
  void _initializeDefaultValue() {
    if (widget.defaultValue != null) {
      if (widget.multiple) {
        // 多选模式：defaultValue应该是List<SelectData<T>>
        if (widget.defaultValue is List) {
          final defaultList = widget.defaultValue as List;
          _selectedValues.clear(); // 清空之前的选中值
          for (final defaultItem in defaultList) {
            if (defaultItem is SelectData<T>) {
              // 检查该项是否在数据列表中存在
              final existingItem = _dataList.firstWhere((item) => item.value == defaultItem.value, orElse: () => defaultItem);
              _selectedValues.add(existingItem);
            }
          }
        }
      } else {
        // 单选模式：defaultValue应该是SelectData<T>
        if (widget.defaultValue is SelectData<T>) {
          final defaultItem = widget.defaultValue as SelectData<T>;
          // 检查该项是否在数据列表中存在
          _selectedValue = _dataList.firstWhere((item) => item.value == defaultItem.value, orElse: () => defaultItem);
        } else {
          // 如果传入的是null，清空选中值
          _selectedValue = null;
        }
      }
    } else {
      // 如果没有默认值，清空选中状态
      _selectedValue = null;
      _selectedValues.clear();
    }
  }

  // 自动加载远程数据（如果需要）
  void _autoLoadRemoteDataIfNeeded() async {
    // 远程搜索模式下的加载逻辑
    if (widget.remote && widget.remoteSearch != null) {
      if (widget.alwaysRefresh) {
        // 如果设置了总是刷新，每次都重新加载数据
        await _handleRemoteFetch();
      } else if (_dataList.isEmpty) {
        // 如果没有设置总是刷新，只在没有初始数据时才自动加载
        await _handleRemoteFetch();
      }
    }
  }

  // 本地筛选（仅当启用filterable时）
  void _handleLocalFilter(String keyword) {
    if (!widget.filterable) return;
    final kw = keyword.trim();
    if (kw.isEmpty) {
      setState(() {
        _filteredList = List.from(_dataList);
      });
      return;
    }
    setState(() {
      _filteredList = _dataList.where((e) => e.label.toLowerCase().contains(kw.toLowerCase())).toList();
    });
  }

  // 远程搜索
  Future<void> _handleRemoteFetch({String? keyword}) async {
    if (!widget.remote || widget.remoteSearch == null) return;

    // 如果没有传入关键字，从搜索控制器获取
    final searchKeyword = keyword ?? _searchController.text.trim();

    setState(() => _isLoading = true);
    try {
      final list = await widget.remoteSearch!.call(searchKeyword);
      setState(() {
        // 直接使用搜索结果，不添加额外的已选中项目
        _dataList = List<SelectData<T>>.from(list);
        _filteredList = List<SelectData<T>>.from(list);

        // 注意：这里不需要修改_selectedValue或_selectedValues
        // 选中状态的判断在build方法中通过比较value来实现
        // 如果搜索结果中包含已选中的项目，它们会自动显示为选中状态
      });

      // 将搜索结果缓存到父组件（特别是空关键字的初始搜索结果）
      if (searchKeyword.isEmpty && widget.onCacheUpdate != null) {
        widget.onCacheUpdate!(list);
      }
    } catch (e) {
      setState(() {
        _dataList = [];
        _filteredList = [];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 处理项目点击事件
  void _onItemTap(SelectData<T> item) {
    setState(() {
      if (widget.multiple) {
        // 多选模式：切换选中状态
        final index = _selectedValues.indexWhere((selectedItem) => selectedItem.value == item.value);
        if (index >= 0) {
          // 已选中，取消选中
          _selectedValues.removeAt(index);
        } else {
          // 未选中，添加到选中列表
          _selectedValues.add(item);
        }
        // 多选模式下不立刻回调，等待点击“确认选择”
      } else {
        // 单选模式：设置选中项
        if (_selectedValue?.value == item.value) {
          // 如果点击的是已选中的项，取消选中
          _selectedValue = null;
        } else {
          // 选中新项
          _selectedValue = item;
        }
        // 单选模式下调用回调并关闭弹窗
        if (widget.onSelected != null) {
          widget.onSelected!(_selectedValue, _selectedValues);
        }
        // 单选模式下选中后自动关闭弹窗
        if (_selectedValue != null) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // 顶部标题区域
          HeaderTitle(title: widget.tips ?? "自定义选择"),
          // 搜索区域 - 根据条件显示
          if (widget.filterable || widget.remote)
            InputSearch(
              remote: widget.remote,
              isLoading: _isLoading,
              controller: _searchController,
              hintText: widget.remote ? '请输入关键字搜索' : '请输入关键字筛选',
              remoteFetch: () => _handleRemoteFetch(keyword: _searchController.text.trim()),
              onChanged: (kw) => _handleLocalFilter(kw),
              onSubmitted: (value) => _handleRemoteFetch(keyword: value),
              onClear: () => _handleLocalFilter(''),
            ),
          // 选项列表
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _isLoading
                  ? LoadingData()
                  : Builder(
                      builder: (context) {
                        // 显示新增按钮
                        final bool showAddFooter = widget.remote && widget.showAdd == true;
                        // 如果数据为空，显示NoData组件
                        if (_dataList.isEmpty) {
                          // 如果配置了远程搜索和新增功能，在NoData下方显示新增按钮
                          if (showAddFooter) {
                            return Column(
                              children: [
                                Expanded(child: NoData()),
                                // 只有输入了关键字才显示新增按钮
                                if (_searchController.text.trim() != '')
                                  InkWell(
                                    onTap: () async {
                                      final String kw = _searchController.text.trim();
                                      final bool? ok = await widget.onAdd?.call(kw);
                                      // 新增成功刷新列表（触发一次搜索）
                                      if (ok == true) {
                                        await _handleRemoteFetch(keyword: kw);
                                      }
                                    },
                                    child: OnAdd(
                                      onAdd: (String innerKw) async {
                                        final bool? ok = await widget.onAdd?.call(innerKw);
                                        // 新增成功刷新列表（触发一次搜索）
                                        if (ok == true) {
                                          await _handleRemoteFetch(keyword: innerKw);
                                        }
                                      },
                                      kw: _searchController.text.trim(),
                                    ),
                                  ),
                              ],
                            );
                          }
                          return NoData();
                        }

                        return ListView.builder(
                          itemCount: _filteredList.length + (showAddFooter ? 1 : 0),
                          itemBuilder: (context, index) {
                            // 判断是否是最底部-显示新增按钮
                            final bool isFooter = showAddFooter && index == _filteredList.length;
                            // 必须输入了关键字查询
                            if (isFooter && _searchController.text.trim() != '') {
                              final String kw = _searchController.text.trim();
                              return InkWell(
                                onTap: () async {
                                  // 调用新增回调，并在返回true时自动刷新列表（触发一次搜索）
                                  final bool? ok = await widget.onAdd?.call(kw);
                                  if (ok == true) {
                                    await _handleRemoteFetch();
                                  }
                                },
                                // 内部显示的"去新增"按钮也使用同样的逻辑
                                child: OnAdd(
                                  onAdd: (String innerKw) async {
                                    final bool? ok = await widget.onAdd?.call(innerKw);
                                    if (ok == true) {
                                      await _handleRemoteFetch();
                                    }
                                  },
                                  kw: kw,
                                ),
                              );
                            }
                            // 如果是footer但没有输入关键字，返回空容器
                            if (isFooter) {
                              return const SizedBox.shrink();
                            }
                            final item = _filteredList[index];
                            final isSelected = widget.multiple == false ? (_selectedValue?.value == item.value) : _selectedValues.any((e) => e.value == item.value);
                            return ChooseItem(
                              // 备选数据
                              item: item,
                              // 是否选中
                              isSelected: isSelected,
                              // 是否多选
                              multiple: widget.multiple,
                              // 点击回调
                              onTap: _onItemTap,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
          // 多选模式下的底部按钮区域
          if (widget.multiple == true)
            Container(
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
                      onPressed: _selectedValues.isEmpty
                          ? null
                          : () {
                              LookChosen.show<T>(
                                context: context,
                                selectedItems: _selectedValues,
                                onSelectedItemsChanged: (updated) {
                                  setState(() {});
                                },
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF),
                        side: BorderSide(color: _selectedValues.isEmpty ? Colors.grey[300]! : const Color(0xFF007AFF), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.check_circle_outline, size: 18, color: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF)),
                      label: Text(
                        '已选择 (${_selectedValues.length})',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _selectedValues.isEmpty ? Colors.grey[400] : const Color(0xFF007AFF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 右侧：确认选择按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectedValues.isEmpty
                          ? null
                          : () {
                              if (widget.onSelected != null) {
                                // 只在确认时回调所选列表
                                widget.onSelected!(null, _selectedValues);
                              }
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedValues.isEmpty ? Colors.grey[200] : const Color(0xFF007AFF),
                        foregroundColor: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.check, size: 18, color: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white),
                      label: Text(
                        '确认选择',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _selectedValues.isEmpty ? Colors.grey[500] : Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
