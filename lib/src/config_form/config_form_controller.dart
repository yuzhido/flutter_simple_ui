import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/form_config.dart';
import 'utils/validation_utils.dart';

class ConfigFormController extends ChangeNotifier {
  GlobalKey<FormState>? _formKey;
  Map<String, dynamic> _formData = {};
  final Map<String, String> _errors = {};
  Function(Map<String, dynamic>)? _onChanged;
  List<FormConfig> _configs = []; // 存储表单配置

  ConfigFormController() {
    _formKey = GlobalKey<FormState>();
  }

  /// 获取表单数据
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);

  /// 获取错误信息
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// 获取表单键
  GlobalKey<FormState>? get formKey => _formKey;

  /// 内部方法，由ConfigForm组件调用
  void setFormKey(GlobalKey<FormState> formKey) {
    _formKey = formKey;
  }

  void setOnChanged(Function(Map<String, dynamic>)? onChanged) {
    _onChanged = onChanged;
  }

  /// 设置表单配置
  void setConfigs(List<FormConfig> configs) {
    _configs = configs;
  }

  /// 初始化表单数据
  void initializeData(Map<String, dynamic> initialData) {
    _formData = Map<String, dynamic>.from(initialData);
    notifyListeners();
  }

  /// 验证表单
  bool validate([List<FormConfig>? configs]) {
    _errors.clear();
    bool isValid = true;
    final List<String> invalidFields = [];

    // 使用传入的配置或内部存储的配置
    final configsToValidate = configs ?? _configs;

    for (var config in configsToValidate) {
      // 只验证显示的字段
      if (!config.isShow) continue;
      if (!config.required) continue;

      if (config.validator != null) {
        final valid = config.validator!(_formData[config.name]);
        if (valid != null) {
          isValid = false;
          _errors[config.name] = valid;
          invalidFields.add(config.name);
        }
      } else if (_formData[config.name] == null || _formData[config.name] == '' || (_formData[config.name] is List && (_formData[config.name] as List).isEmpty)) {
        isValid = false;
        _errors[config.name] = ValidationUtils.getDefaultErrorMessage(config);
        invalidFields.add(config.name);
      }
    }

    if (!isValid) {
      debugPrint('校验失败的字段: ${invalidFields.join(', ')}');
    }

    // 触发表单重新验证以显示错误
    _formKey?.currentState?.validate();
    notifyListeners();
    return isValid;
  }

  /// 获取表单数据
  Map<String, dynamic> getFormData() {
    return Map<String, dynamic>.from(_formData);
  }

  /// 重置表单
  void reset() {
    _formData.clear();
    _errors.clear();
    _formKey?.currentState?.reset();
    notifyListeners();
  }

  /// 保存表单（验证并获取数据）
  Map<String, dynamic>? save([List<FormConfig>? configs]) {
    if (validate(configs)) {
      return getFormData();
    }
    return null;
  }

  /// 更新字段值
  void updateField(String fieldName, dynamic value) {
    _formData[fieldName] = value;
    _errors.remove(fieldName); // 清除该字段的错误
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 获取字段值
  T? getValue<T>(String fieldName) {
    final value = _formData[fieldName];
    if (value == null) return null;

    // 处理类型转换，避免强制转换错误
    if (T == String && value is List) {
      // 如果是 List 但期望 String，返回空字符串
      return '' as T;
    } else if (T == String && value is! String) {
      // 如果不是 String 但期望 String，转换为字符串
      return value.toString() as T;
    }

    return value as T?;
  }

  /// 设置字段值
  void setFieldValue(String fieldName, dynamic value) {
    updateField(fieldName, value);
  }

  /// 批量设置字段值
  void setFieldValues(Map<String, dynamic> values) {
    _formData.addAll(values);
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 清空字段值
  void clearFieldValue(String fieldName) {
    _formData.remove(fieldName);
    _errors.remove(fieldName);
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 清空所有字段值
  void clearAllFields() {
    _formData.clear();
    _errors.clear();
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 设置字段错误
  void setFieldError(String fieldName, String error) {
    _errors[fieldName] = error;
    notifyListeners();
  }

  /// 清除字段错误
  void clearFieldError(String fieldName) {
    _errors.remove(fieldName);
    notifyListeners();
  }

  /// 重置字段为默认值
  void resetFieldToDefault(String fieldName) {
    // 从配置中找到对应字段的默认值
    final config = _configs.firstWhere((config) => config.name == fieldName, orElse: () => throw ArgumentError('Field $fieldName not found in configs'));

    if (config.defaultValue != null) {
      _formData[fieldName] = config.defaultValue;
    } else {
      _formData.remove(fieldName);
    }

    _errors.remove(fieldName);
    notifyListeners();
    _onChanged?.call(_formData);
  }

  /// 批量重置字段为默认值
  void resetFieldsToDefault(List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      final config = _configs.where((config) => config.name == fieldName).firstOrNull;
      if (config != null) {
        if (config.defaultValue != null) {
          _formData[fieldName] = config.defaultValue;
        } else {
          _formData.remove(fieldName);
        }
        _errors.remove(fieldName);
      }
    }
    notifyListeners();
    _onChanged?.call(_formData);
  }
}
