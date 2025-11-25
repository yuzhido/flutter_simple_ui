import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';
import 'package:flutter_simple_ui/src/dropdown_choose/widgets/choose_content.dart';
import 'package:flutter_simple_ui/src/widgets/dropdown_container.dart';

class DropdownChooseController {
  VoidCallback? _clearAction;
  void _bindClear(VoidCallback action) {
    _clearAction = action;
  }

  void _unbind() {
    _clearAction = null;
  }

  void clear() {
    _clearAction?.call();
  }
}

class DropdownChoose<T> extends StatefulWidget {
  // 是否可以过滤
  final bool filterable;
  // 是否开启远程搜索
  final bool remote;
  // 远程搜索方法-一个返回Future<List<SelectData<T>>>的函数
  final Future<List<SelectData<T>>> Function(String)? remoteSearch;
  // 是否总是刷新数据（仅在remote为true时有效）
  final bool alwaysRefresh;
  // 是否显示新增按钮
  final bool showAdd;
  final bool showClear;
  // 是否多选
  final bool multiple;
  // 新增回调
  final Future<bool?> Function(String)? onAdd;
  // 单选模式回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选模式回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;
  // 缓存更新回调 - 当远程搜索或其他操作更新缓存数据时调用
  final void Function(List<SelectData<T>>)? onCacheUpdate;
  final VoidCallback? onClear;
  // 默认展示的数据
  final List<SelectData<T>> options;
  // 占位符文本
  final String tips;
  // 默认选中的数据 - 支持单个或多个
  final dynamic defaultValue; // SelectData<T> 或 List<SelectData<T>>
  // 控制器
  final DropdownChooseController? controller;
  const DropdownChoose({
    super.key,
    this.filterable = false,
    this.remote = false,
    this.alwaysRefresh = false,
    this.showAdd = false,
    this.showClear = false,
    this.multiple = false,
    this.onAdd,
    this.onSingleChanged,
    this.onMultipleChanged,
    this.onCacheUpdate,
    this.options = const [],
    this.defaultValue,
    this.tips = '',
    this.remoteSearch,
    this.onClear,
    this.controller,
  }) : assert(defaultValue == null || defaultValue is SelectData<T> || defaultValue is List<SelectData<T>>, 'defaultValue 必须是 null、SelectData<T> 或 List<SelectData<T>> 类型'),
       assert(!remote || remoteSearch != null, 'remote为 true 时必须提供 remoteSearch'),
       assert(!(filterable && remote), 'filterable 和 remote 不能同时为 true，请选择本地过滤或远程搜索其中一种模式');
  @override
  State<DropdownChoose<T>> createState() => _DropdownChooseState<T>();
}

class _DropdownChooseState<T> extends State<DropdownChoose<T>> {
  // 当前选中的值
  SelectData<T>? _selectedValue;
  final List<SelectData<T>> _selectedValues = [];
  // 是否正在选择
  bool isChoosing = false;
  // 缓存的远程数据
  List<SelectData<T>> _cachedOptions = [];

  @override
  void initState() {
    super.initState();
    // 初始化默认值
    _initDefaultValue();
    // 初始化缓存数据（仅缓存外界传递的options）
    _initCachedOptions();
    widget.controller?._bindClear(_clearSelection);
  }

  @override
  void dispose() {
    widget.controller?._unbind();
    super.dispose();
  }

  // 初始化默认值
  void _initDefaultValue() {
    if (widget.defaultValue != null) {
      if (widget.multiple) {
        // 多选模式：defaultValue应该是List<SelectData<T>>
        if (widget.defaultValue is List<SelectData<T>>) {
          _selectedValues.clear();
          _selectedValues.addAll(widget.defaultValue as List<SelectData<T>>);
        }
      } else {
        // 单选模式：defaultValue应该是SelectData<T>
        if (widget.defaultValue is SelectData<T>) {
          _selectedValue = widget.defaultValue as SelectData<T>;
        }
      }
    }
  }

  // 初始化缓存数据
  void _initCachedOptions() {
    // 如果外界传递了options，将其缓存起来
    if (widget.options.isNotEmpty) {
      _cachedOptions = List.from(widget.options);
    }
    // 注意：远程搜索模式下，不在初始化时加载数据，而是在点击弹窗时才加载
  }

  // 获取有效的options数据
  List<SelectData<T>> _getEffectiveOptions() {
    List<SelectData<T>> effectiveOptions;

    if (widget.remote) {
      // 远程搜索模式：优先使用缓存的远程数据
      if (_cachedOptions.isNotEmpty) {
        effectiveOptions = List.from(_cachedOptions);
      } else {
        // 如果还没有缓存数据，返回空列表（等待加载）
        effectiveOptions = <SelectData<T>>[];
      }
    } else {
      // 非远程搜索模式：使用外界传递的options或缓存的options
      if (_cachedOptions.isNotEmpty) {
        effectiveOptions = List.from(_cachedOptions);
      } else {
        effectiveOptions = List.from(widget.options);
      }
    }

    // 确保选中的数据也包含在options中，以便正确显示选中状态
    return _mergeSelectedItemsWithOptions(effectiveOptions);
  }

  // 将选中的项目合并到options中，确保选中状态能正确显示
  List<SelectData<T>> _mergeSelectedItemsWithOptions(List<SelectData<T>> options) {
    final Set<dynamic> existingValues = options.map((e) => e.value).toSet();
    final List<SelectData<T>> mergedOptions = List.from(options);

    if (widget.multiple) {
      // 多选模式：将不在options中的选中项添加到列表开头
      for (final selectedItem in _selectedValues) {
        if (!existingValues.contains(selectedItem.value)) {
          mergedOptions.insert(0, selectedItem);
        }
      }
    } else {
      // 单选模式：如果选中项不在options中，添加到列表开头
      if (_selectedValue != null && !existingValues.contains(_selectedValue!.value)) {
        mergedOptions.insert(0, _selectedValue!);
      }
    }

    return mergedOptions;
  }

  // 处理选中回调
  void _onSelected(SelectData<T>? selectedValue, List<SelectData<T>>? selectedValues) {
    setState(() {
      _selectedValue = selectedValue;
      _selectedValues.clear();
      _selectedValues.addAll(selectedValues ?? []);
    });

    // 调用外部回调
    if (selectedValues != null) {
      // 多选模式：调用多选回调
      if (widget.onMultipleChanged != null) {
        final values = _selectedValues.map((e) => e.value).toList(); // List<dynamic>
        final datas = _selectedValues.map((e) => e.data).toList(); // List<T>
        widget.onMultipleChanged!(values, datas, _selectedValues);
      }
    }
    if (selectedValue != null) {
      // 单选模式：调用单选回调
      final value = selectedValue.value; // dynamic
      final data = selectedValue.data; // T?
      widget.onSingleChanged!(value, data, selectedValue);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedValue = null;
      _selectedValues.clear();
    });
    if (widget.multiple) {
      if (widget.onMultipleChanged != null) {
        widget.onMultipleChanged!(const [], const [], const []);
      }
    }
    widget.onClear?.call();
  }

  // 更新缓存数据（由ChooseContent回调）
  void _updateCache(List<SelectData<T>> newData) {
    setState(() {
      _cachedOptions = List.from(newData);
    });

    // 通知外部组件缓存数据已更新
    if (widget.onCacheUpdate != null) {
      widget.onCacheUpdate!(List.from(newData));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = widget.multiple ? _selectedValues.isNotEmpty : _selectedValue != null;
    return InkWell(
      onTap: _showDialog,
      child: DropdownContainer(
        isChoosing: isChoosing,
        showClear: widget.showClear,
        onClear: _clearSelection,
        hasSelection: hasSelection,
        item: _selectedValue,
        items: _selectedValues,
        multiple: widget.multiple,
        tips: widget.tips,
      ),
    );
  }

  // 显示弹窗
  _showDialog() async {
    setState(() => isChoosing = true);
    if (!mounted) {
      setState(() => isChoosing = false);
      return;
    }

    // 显示弹窗
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: ChooseContent<T>(
            tips: widget.tips,
            options: _getEffectiveOptions(),
            filterable: widget.filterable,
            remote: widget.remote,
            remoteSearch: widget.remoteSearch,
            alwaysRefresh: widget.alwaysRefresh,
            showAdd: widget.showAdd,
            multiple: widget.multiple,
            defaultValue: widget.multiple ? _selectedValues : _selectedValue,
            onSelected: _onSelected,
            onAdd: widget.onAdd,
            onCacheUpdate: _updateCache,
          ),
        );
      },
    );
    setState(() => isChoosing = false);
  }
}
