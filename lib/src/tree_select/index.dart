import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';
import 'package:flutter_simple_ui/src/tree_select/widgets/look_chosen.dart';
import 'package:flutter_simple_ui/src/widgets/bottom_action.dart';
import 'package:flutter_simple_ui/src/widgets/dropdown_container.dart';
import 'package:flutter_simple_ui/src/widgets/header_title.dart';
import 'package:flutter_simple_ui/src/widgets/input_search.dart';
import 'package:flutter_simple_ui/src/widgets/tree_choose_item.dart';

// 树形结构数据选择组件
class TreeSelect<T> extends StatefulWidget {
  // 默认值
  final List<SelectData<T>>? defaultValue;
  // 备选数据
  final List<SelectData<T>> options;

  // 单选模式回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选模式回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;
  // 选择模式
  final bool multiple;
  // 顶部title
  final String? title;
  // 顶部tips
  final String? tips;
  // 顶部提示
  final String hintText;
  // 远程搜索
  final Future<List<SelectData<T>>> Function(String)? remoteFetch;
  // 是否开启远程搜索
  final bool remote;
  // 是否可过滤
  final bool filterable;
  // 是否懒加载
  final bool lazyLoad;
  // 懒加载函数 - 传入父节点，返回子节点列表
  final Future<List<SelectData<T>>> Function(SelectData<T>)? lazyLoadFetch;
  // 是否缓存数据
  final bool isCacheData;

  const TreeSelect({
    super.key,
    this.defaultValue,
    this.options = const [],
    this.onSingleChanged,
    this.onMultipleChanged,
    this.multiple = false,
    this.title,
    this.tips,
    this.hintText = '请输入关键字搜索',

    this.remoteFetch,
    this.remote = false,
    this.filterable = false,
    this.lazyLoad = false,
    this.lazyLoadFetch,
    this.isCacheData = true,
  }) : assert(!remote || remoteFetch != null, 'remote为true时必须传递remoteFetch参数'),
       assert(!lazyLoad || lazyLoadFetch != null, 'lazyLoad为true时必须传递lazyLoadFetch参数');

  @override
  State<TreeSelect<T>> createState() => _TreeSelectState<T>();
}

class _TreeSelectState<T> extends State<TreeSelect<T>> {
  // 是否正在选择
  bool isChoosing = false;
  // 树形结构数据
  List<SelectData<T>> dataList = [];
  // 过滤后的数据
  List<SelectData<T>> filteredDataList = [];
  // 当前选中的数据
  SelectData<T>? selectedItem;
  List<SelectData<T>> selectedItems = [];
  // 展开状态管理
  Set<dynamic> expandedItems = <dynamic>{};
  // 是否正在加载远程数据
  bool isLoadingRemote = false;
  // 搜索控制器
  late TextEditingController _searchController;
  // 懒加载状态管理 - 记录正在加载的节点
  Set<dynamic> loadingItems = <dynamic>{};
  // 缓存数据 - 存储初始数据（不是搜索结果）
  List<SelectData<T>> cachedData = [];
  // 是否已经缓存了数据
  bool hasCachedData = false;

  @override
  void initState() {
    super.initState();
    dataList = widget.options;
    filteredDataList = widget.options;
    _searchController = TextEditingController();

    // 如果启用缓存且有本地数据，则缓存本地数据
    if (widget.isCacheData && widget.options.isNotEmpty) {
      cachedData = List.from(widget.options);
      hasCachedData = true;
    }

    // 初始化默认选中值
    if (widget.defaultValue != null && widget.defaultValue!.isNotEmpty) {
      if (widget.multiple) {
        selectedItems = List.from(widget.defaultValue!);
      } else {
        selectedItem = widget.defaultValue!.first;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 清除缓存数据
  void clearCache() {
    setState(() {
      cachedData.clear();
      hasCachedData = false;
    });
  }

  // 查找指定值在树形数据中的路径
  List<dynamic>? _findPathToValue(List<SelectData<T>> data, dynamic targetValue, [List<dynamic>? currentPath]) {
    currentPath ??= [];

    for (final item in data) {
      final newPath = [...currentPath, item.value];

      // 如果找到目标值，返回路径
      if (item.value == targetValue) {
        return newPath;
      }

      // 如果有子节点，递归查找
      if (item.children != null && item.children!.isNotEmpty) {
        final foundPath = _findPathToValue(item.children!, targetValue, newPath);
        if (foundPath != null) {
          return foundPath;
        }
      }
    }

    return null;
  }

  // 自动展开到选中值的路径
  void _expandToSelectedValue() {
    if (!widget.isCacheData || !hasCachedData || cachedData.isEmpty) return;

    // 清除之前的展开状态
    expandedItems.clear();

    if (widget.multiple && selectedItems.isNotEmpty) {
      // 多选模式：为所有选中项展开路径
      for (final selectedItem in selectedItems) {
        final path = _findPathToValue(cachedData, selectedItem.value);
        if (path != null && path.length > 1) {
          // 展开路径上的所有父节点（除了最后一个节点本身）
          for (int i = 0; i < path.length - 1; i++) {
            expandedItems.add(path[i]);
          }
        }
      }
    } else if (!widget.multiple && selectedItem != null) {
      // 单选模式：展开到选中项
      final path = _findPathToValue(cachedData, selectedItem!.value);
      if (path != null && path.length > 1) {
        // 展开路径上的所有父节点（除了最后一个节点本身）
        for (int i = 0; i < path.length - 1; i++) {
          expandedItems.add(path[i]);
        }
      }
    }
  }

  // 本地过滤数据
  List<SelectData<T>> _filterLocalData(List<SelectData<T>> data, String keyword) {
    if (keyword.isEmpty) return data;

    List<SelectData<T>> result = [];

    for (final item in data) {
      // 检查当前项是否匹配
      bool currentMatches = item.label.toLowerCase().contains(keyword.toLowerCase());

      // 递归检查子项
      List<SelectData<T>>? filteredChildren;
      if (item.children != null && item.children!.isNotEmpty) {
        filteredChildren = _filterLocalData(item.children!, keyword);
      }

      // 如果当前项匹配或有匹配的子项，则包含此项
      if (currentMatches || (filteredChildren != null && filteredChildren.isNotEmpty)) {
        result.add(SelectData<T>(label: item.label, value: item.value, data: item.data, hasChildren: item.hasChildren, children: filteredChildren ?? item.children));
      }
    }

    return result;
  }

  // 处理本地搜索
  void _handleLocalSearch(String keyword, Function setModalState) {
    if (widget.filterable && !widget.remote) {
      setState(() {
        if (keyword.isEmpty) {
          // 搜索框清空时，恢复原始数据并展开到选中值
          filteredDataList = dataList;
          if (widget.isCacheData && hasCachedData) {
            _expandToSelectedValue();
          }
        } else {
          // 有搜索关键字时，清除展开状态并过滤数据
          expandedItems.clear();
          filteredDataList = _filterLocalData(dataList, keyword);
        }
      });
    }
    setModalState(() {});
  }

  // 懒加载子节点数据
  Future<void> _loadChildrenData(SelectData<T> parentItem, Function setModalState) async {
    if (!widget.lazyLoad || widget.lazyLoadFetch == null) return;
    // 设置加载状态
    setModalState(() {
      loadingItems.add(parentItem.value);
    });
    try {
      // 调用懒加载函数获取子节点数据
      final children = await widget.lazyLoadFetch!(parentItem);
      // 更新父节点的children数据
      _updateItemChildren(parentItem, children);
      // 展开该节点
      setState(() {
        expandedItems.add(parentItem.value);
      });
    } catch (e) {
      debugPrint('懒加载失败: $e');
    } finally {
      // 清除加载状态
      setModalState(() {
        loadingItems.remove(parentItem.value);
      });
    }
  }

  // 更新指定项的子节点数据
  void _updateItemChildren(SelectData<T> targetItem, List<SelectData<T>> children) {
    void updateInList(List<SelectData<T>> list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].value == targetItem.value) {
          // 创建新的SelectData对象，包含子节点数据
          list[i] = SelectData<T>(label: list[i].label, value: list[i].value, data: list[i].data, hasChildren: list[i].hasChildren, children: children);
          return;
        }
        // 递归查找子节点
        if (list[i].children != null) {
          updateInList(list[i].children!);
        }
      }
    }

    setState(() {
      updateInList(dataList);
      updateInList(filteredDataList);

      // 如果启用缓存，同时更新缓存数据
      if (widget.isCacheData && hasCachedData) {
        updateInList(cachedData);
      }
    });
  }

  // 将树形数据扁平化为列表，根据展开状态显示
  List<Map<String, dynamic>> _flattenTreeData(List<SelectData<T>> data, {int level = 0}) {
    List<Map<String, dynamic>> result = [];
    for (final item in data) {
      // 检查是否正在加载
      final isLoading = loadingItems.contains(item.value);
      // 添加当前项
      result.add({'data': item, 'level': level, 'isExpanded': expandedItems.contains(item.value), 'hasChildren': item.hasChildren, 'isLoading': isLoading});
      // 如果当前项已展开且有子项，递归添加子项
      if (expandedItems.contains(item.value) && item.children != null && item.children!.isNotEmpty) {
        result.addAll(_flattenTreeData(item.children!, level: level + 1));
      }
    }

    return result;
  }

  // 切换展开/收起状态
  void _toggleExpanded(SelectData<T> item, Function setModalState) {
    if (widget.lazyLoad && item.hasChildren && (item.children == null || item.children!.isEmpty)) {
      // 懒加载模式下，如果没有子数据则加载
      _loadChildrenData(item, setModalState);
    } else {
      // 普通模式下直接切换展开状态
      setState(() {
        if (expandedItems.contains(item.value)) {
          expandedItems.remove(item.value);
        } else {
          expandedItems.add(item.value);
        }
      });
      setModalState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击显示弹窗
      onTap: _showBottomSheet,
      child: DropdownContainer<T>(
        // 是否正在选择
        isChoosing: isChoosing,
        multiple: widget.multiple,
        item: selectedItem,
        items: selectedItems,
        tips: widget.tips ?? '请选择',
      ),
    );
  }

  // 处理单选选中
  void _onItemSelected(SelectData<T>? item) {
    if (item == null) return;
    setState(() {
      selectedItem = item;
    });
    // 触发单选回调 - 传递实际值和选中项
    if (widget.onSingleChanged != null) {
      widget.onSingleChanged!(item.value, item.data, item);
    }

    // 单选模式下选中后关闭弹窗
    Navigator.of(context).pop();
  }

  // 处理多选选中
  void _onItemToggled(SelectData<T> item) {
    setState(() {
      if (selectedItems.any((selected) => selected.value == item.value)) {
        selectedItems.removeWhere((selected) => selected.value == item.value);
      } else {
        selectedItems.add(item);
      }
    });
  }

  // 查看已选按钮
  void _onLookChosen(StateSetter setModalState) {
    LookChosen.show<T>(
      context: context,
      selectedItems: selectedItems, // 直接传入选中数据
      onSelectedItemsChanged: (updatedItems) {
        setState(() {
          selectedItems = updatedItems;
        });
      },
      setModalState: setModalState, // 传递主弹窗刷新回调
    );
  }

  // 确认多选结果
  void _confirmMultipleSelection() {
    // 触发多选回调 - 传递实际值列表和选中项列表
    if (widget.onMultipleChanged != null) {
      List<dynamic> values = [];
      List<T> datas = [];
      for (var item in selectedItems) {
        datas.add(item.data);
        values.add(item.value);
      }
      widget.onMultipleChanged!(values, datas, selectedItems);
    }
    Navigator.of(context).pop();
  }

  // 远程搜索
  onRemoteSearch(refresh) async {
    if (widget.remote != true) return;

    final keyword = _searchController.text.trim();

    // 先设置加载状态为true
    refresh(() {
      isLoadingRemote = true;
    });

    try {
      final remoteData = await widget.remoteFetch!(keyword);

      // 如果启用缓存且是初始加载（空关键字），保存到缓存
      if (widget.isCacheData && keyword.isEmpty && !hasCachedData) {
        cachedData = List.from(remoteData);
        hasCachedData = true;
        // 同时更新dataList，作为后续搜索的基础数据
        dataList = List.from(remoteData);
      }

      refresh(() {
        filteredDataList = remoteData;
        isLoadingRemote = false;

        // 如果是清空搜索（空关键字）且有缓存，展开到选中值
        if (keyword.isEmpty && widget.isCacheData && hasCachedData) {
          _expandToSelectedValue();
        } else if (keyword.isNotEmpty) {
          // 有搜索关键字时，清除展开状态
          expandedItems.clear();
        }
      });
    } catch (e) {
      refresh(() {
        filteredDataList = [];
        isLoadingRemote = false;
      });
    }
  }

  // 加载初始数据（用于远程搜索模式的初始化）
  Future<void> _loadInitialData(Function refresh) async {
    if (!widget.remote || widget.remoteFetch == null) return;

    // 如果已有缓存数据，直接使用
    if (widget.isCacheData && hasCachedData && cachedData.isNotEmpty) {
      refresh(() {
        filteredDataList = cachedData;
        dataList = cachedData; // 更新基础数据
        isLoadingRemote = false;
      });
      return;
    }

    // 加载初始数据（空关键字搜索）
    refresh(() {
      isLoadingRemote = true;
    });

    try {
      final initialData = await widget.remoteFetch!(''); // 空关键字获取初始数据

      // 缓存初始数据
      if (widget.isCacheData) {
        cachedData = List.from(initialData);
        hasCachedData = true;
      }

      refresh(() {
        filteredDataList = initialData;
        dataList = initialData; // 更新基础数据
        isLoadingRemote = false;
      });
    } catch (e) {
      refresh(() {
        filteredDataList = [];
        isLoadingRemote = false;
      });
    }
  }

  _showBottomSheet() async {
    // 改变箭头
    setState(() => isChoosing = true);
    // 重置搜索状态
    if (widget.isCacheData && hasCachedData && cachedData.isNotEmpty) {
      // 如果有缓存数据，优先使用缓存数据
      filteredDataList = cachedData;
      dataList = cachedData; // 同时更新基础数据
      // 自动展开到选中值的路径
      _expandToSelectedValue();
    } else {
      filteredDataList = dataList;
    }
    _searchController.clear();

    // 立即显示弹窗，不等待数据加载
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // 远程搜索模式下，首次显示弹窗时加载初始数据
            // 只有在没有缓存数据或缓存被禁用时才需要加载
            if (widget.remote && filteredDataList.isEmpty && !isLoadingRemote && (!widget.isCacheData || !hasCachedData)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadInitialData(setModalState);
              });
            }

            // 获取扁平化的数据列表
            final flattenedData = _flattenTreeData(filteredDataList);

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部title区域
                  HeaderTitle(title: widget.title ?? (widget.multiple ? '请选择选项(可多选)' : '请选择选项')),

                  // 搜索区域 - 根据条件显示
                  if (widget.remote || widget.filterable)
                    InputSearch(
                      remote: widget.remote,
                      isLoading: isLoadingRemote,
                      hintText: widget.hintText,
                      controller: _searchController,
                      remoteFetch: () => onRemoteSearch(setModalState),
                      onChanged: (keyword) => _handleLocalSearch(keyword, setModalState),
                    ),

                  Expanded(
                    child: isLoadingRemote
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: flattenedData.length,
                            itemBuilder: (context, index) {
                              final itemData = flattenedData[index];
                              final item = itemData['data'] as SelectData<T>;
                              final level = itemData['level'] as int;
                              final isExpanded = itemData['isExpanded'] as bool;
                              final hasChildren = itemData['hasChildren'] as bool;
                              final isLoading = itemData['isLoading'] as bool;
                              final isSelected = widget.multiple ? selectedItems.any((selected) => selected.value == item.value) : selectedItem?.value == item.value;

                              return TreeChooseItem<T>(
                                data: item,
                                isSelected: isSelected,
                                multiple: widget.multiple,
                                level: level,
                                isExpanded: isExpanded,
                                hasChildren: hasChildren,
                                isLoading: isLoading,
                                onTap: (selectedData) {
                                  if (widget.multiple) {
                                    _onItemToggled(selectedData!);
                                    setModalState(() {}); // 更新弹窗内的状态
                                  } else {
                                    _onItemSelected(selectedData);
                                  }
                                },
                                onExpandToggle: hasChildren
                                    ? () {
                                        _toggleExpanded(item, setModalState);
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),

                  // 底部按钮区域（仅多选模式显示）
                  if (widget.multiple)
                    BottomAction(
                      selectedValues: selectedItems,
                      // 点击查看已选按钮
                      onLookChosen: () => _onLookChosen(setModalState),
                      // 点击确认选择按钮
                      onSureChosen: _confirmMultipleSelection,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
    // 恢复箭头
    setState(() => isChoosing = false);
  }
}
