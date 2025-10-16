import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class ConfigForm extends StatefulWidget {
  // 表单配置
  final List<FormConfig> configs;
  // 表单初始值
  final Map<String, dynamic>? initialValues;
  // 表单数据改变回调
  final Function(Map<String, dynamic>)? onChanged;
  // 表单提交按钮构建回调
  final Widget Function(Map<String, dynamic> formData)? submitBuilder;
  // 表单控制器
  final ConfigFormController? controller;

  const ConfigForm({super.key, required this.configs, this.initialValues, this.onChanged, this.submitBuilder, this.controller});

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  late ConfigFormController _controller;
  Map<String, Key?> _previousKeys = {}; // 存储上一次的key状态

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ConfigFormController();
    _initializeFormData();
    _initializeController();
    _updatePreviousKeys(); // 初始化key状态
  }

  @override
  void didUpdateWidget(covariant ConfigForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? ConfigFormController();
      _initializeController();
    }
    // The configs can change on each rebuild (e.g. isShow property),
    // so we need to update them in the controller.
    _controller.setConfigs(widget.configs);
  }

  void _initializeController() {
    _controller.setOnChanged(widget.onChanged);
    _controller.setConfigs(widget.configs);
  }

  void _initializeFormData() {
    final initialData = Map<String, dynamic>.from(widget.initialValues ?? {});

    // 设置默认值
    for (var config in widget.configs) {
      if (!initialData.containsKey(config.name) && config.defaultValue != null) {
        initialData[config.name] = config.defaultValue;
      }
    }

    _controller.initializeData(initialData);
  }

  /// 更新key状态记录
  void _updatePreviousKeys() {
    _previousKeys.clear();
    for (var config in widget.configs) {
      _previousKeys[config.name] = config.key;
    }
  }

  /// 检查并处理key变化
  void _handleKeyChanges() {
    final List<String> fieldsToReset = [];

    for (var config in widget.configs) {
      final previousKey = _previousKeys[config.name];
      final currentKey = config.key;

      // 如果key发生了变化，记录需要重置的字段
      if (previousKey != currentKey) {
        fieldsToReset.add(config.name);
      }
    }

    // 批量重置字段为默认值
    if (fieldsToReset.isNotEmpty) {
      _controller.resetFieldsToDefault(fieldsToReset);
    }

    // 更新key状态
    _updatePreviousKeys();
  }

  @override
  void dispose() {
    // 只有当 controller 是内部创建的时候才 dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 在每次build时检查key变化
    _handleKeyChanges();

    return Form(
      key: _controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.configs.where((config) => config.isShow).map((config) {
            if (config.type == FormType.text) {
              return InputForText(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.number) {
              return InputForNumber(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.integer) {
              return InputForInteger(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.textarea) {
              return InputForTextarea(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.radio) {
              return SelectForRadio(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.checkbox) {
              return SelectForCheckbox(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.select) {
              return SelectForSelect(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.dropdown) {
              return SelectForDropdown(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.treeSelect) {
              return SelectForTree(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.date) {
              return DateTimeForDate(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.time) {
              return DateTimeForTime(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.datetime) {
              return DateTimeForDateTime(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.upload) {
              return UploadForFile(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else if (config.type == FormType.custom) {
              return CustomForAny(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            } else {
              return InputForText(key: config.key, config: config, controller: _controller, onChanged: widget.onChanged);
            }
          }),
        ],
      ),
    );
  }
}
