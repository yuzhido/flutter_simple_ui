import 'package:flutter_simple_ui/models/form_type.dart';
import 'package:flutter_simple_ui/models/form_config.dart';

/// 表单数据解析工具类
/// 专门处理从字符串到实际数据类型的转换
class FormDataParser {
  /// 将表单输入值转换为期望的数据类型
  static dynamic parseFormValue(dynamic value, FormConfig config) {
    if (value == null) return null;

    final fieldType = config.type;
    final fieldConfig = config;

    switch (fieldType) {
      case FormType.number:
        return _parseNumber(value);
      case FormType.integer:
        return _parseInteger(value);
      case FormType.radio:
        return _parseRadio(value, fieldConfig);
      case FormType.select:
        return _parseSelect(value, fieldConfig);
      case FormType.checkbox:
        return _parseCheckbox(value, fieldConfig);
      case FormType.dropdown:
        return _parseDropdown(value, fieldConfig);
      case FormType.treeSelect:
        return _parseTreeSelect(value, fieldConfig);
      default:
        return value;
    }
  }

  /// 解析数字类型
  static double? _parseNumber(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : double.tryParse(str);
  }

  /// 解析整数类型
  static int? _parseInteger(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : int.tryParse(str);
  }

  /// 解析单选类型
  static dynamic _parseRadio(dynamic value, dynamic fieldConfig) {
    try {
      final options = (fieldConfig as dynamic).options as List<dynamic>;
      final opt = options.where((o) => (o.value?.toString() ?? '') == (value?.toString() ?? '')).firstOrNull;
      return opt?.value;
    } catch (_) {
      return value;
    }
  }

  /// 解析下拉选择类型
  static dynamic _parseSelect(dynamic value, dynamic fieldConfig) {
    try {
      final cfg = fieldConfig as dynamic;
      final options = cfg.options as List<dynamic>;

      dynamic toOriginal(String s) {
        final found = options.where((o) => (o.value?.toString() ?? '') == s).firstOrNull;
        return found?.value ?? s;
      }

      final str = value?.toString() ?? '';
      if (cfg.multiple == true) {
        return _parseMultipleValues(str, toOriginal);
      } else {
        return str.isEmpty ? null : toOriginal(str);
      }
    } catch (_) {
      return value;
    }
  }

  /// 解析复选框类型
  static List<dynamic> _parseCheckbox(dynamic value, dynamic fieldConfig) {
    try {
      final options = (fieldConfig as dynamic).options as List<dynamic>;

      dynamic mapOne(String s) {
        final found = options.where((o) => (o.value?.toString() ?? '') == s).firstOrNull;
        return found?.value ?? s;
      }

      final str = value?.toString() ?? '';
      if (str.isEmpty) {
        return <dynamic>[];
      } else {
        return str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).map(mapOne).toList();
      }
    } catch (_) {
      return value is List ? value : <dynamic>[];
    }
  }

  /// 解析下拉选择器类型
  static dynamic _parseDropdown(dynamic value, dynamic fieldConfig) {
    try {
      final cfg = fieldConfig as dynamic;
      final options = cfg.options as List<dynamic>;

      dynamic toOriginal(String s) {
        final found = options.where((o) => (o.value?.toString() ?? '') == s).firstOrNull;
        return found?.value ?? s;
      }

      final str = value?.toString() ?? '';
      if (cfg.multiple == true) {
        return _parseMultipleValues(str, toOriginal);
      } else {
        return str.isEmpty ? null : toOriginal(str);
      }
    } catch (_) {
      return value;
    }
  }

  /// 解析树形选择类型
  static dynamic _parseTreeSelect(dynamic value, dynamic fieldConfig) {
    try {
      final cfg = fieldConfig as dynamic;
      final options = cfg.options as List<dynamic>;

      // 深度搜索树节点
      List<dynamic> flatten(List<dynamic> nodes) {
        final result = <dynamic>[];
        for (final n in nodes) {
          result.add(n);
          final children = (n.children as List<dynamic>?) ?? const [];
          if (children.isNotEmpty) {
            result.addAll(flatten(children));
          }
        }
        return result;
      }

      final flatOptions = flatten(options);
      dynamic toOriginal(String s) {
        final found = flatOptions.where((o) => (o.value?.toString() ?? '') == s).firstOrNull;
        return found?.value ?? s;
      }

      final str = value?.toString() ?? '';
      if (cfg.multiple == true) {
        return _parseMultipleValues(str, toOriginal);
      } else {
        return str.isEmpty ? null : toOriginal(str);
      }
    } catch (_) {
      return value;
    }
  }

  /// 解析多选值的通用方法
  static List<dynamic> _parseMultipleValues(String str, dynamic Function(String) converter) {
    if (str.isEmpty) {
      return <dynamic>[];
    } else {
      final parts = str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return parts.map(converter).toList();
    }
  }
}
