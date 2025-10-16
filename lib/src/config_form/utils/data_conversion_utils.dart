import 'package:flutter_simple_ui/models/form_type.dart';

/// 数据转换工具类
/// 统一处理表单字段的数据类型转换
class DataConversionUtils {
  /// 将任意类型的值转换为适合TextEditingController的字符串
  /// 这是统一的数据转换入口，避免List被错误转换为"[item1,item2]"格式
  static String valueToControllerText(dynamic value, FormType fieldType) {
    if (value == null) return '';

    switch (fieldType) {
      case FormType.checkbox:
        // 对于checkbox，如果是List类型，需要特殊处理
        if (value is List) {
          // 如果是SelectData列表，提取value
          if (value.isNotEmpty && value.first.runtimeType.toString().contains('SelectData')) {
            return value.map((e) => e.value?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
          }
          // 如果是普通值列表
          return value.map((e) => e.toString()).where((s) => s.isNotEmpty).join(',');
        }
        return value.toString();

      case FormType.select:
      case FormType.dropdown:
        // 对于select和dropdown，处理单选和多选
        if (value is List) {
          if (value.isNotEmpty && value.first.runtimeType.toString().contains('SelectData')) {
            return value.map((e) => e.value?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
          }
          return value.map((e) => e.toString()).where((s) => s.isNotEmpty).join(',');
        }
        // 如果是SelectData对象
        if (value.runtimeType.toString().contains('SelectData')) {
          return value.value?.toString() ?? '';
        }
        return value.toString();

      case FormType.radio:
        // 对于radio，如果是SelectData对象
        if (value.runtimeType.toString().contains('SelectData')) {
          return value.value?.toString() ?? '';
        }
        return value.toString();

      case FormType.treeSelect:
        // 对于treeSelect，处理单选和多选
        if (value is List) {
          if (value.isNotEmpty && value.first.runtimeType.toString().contains('SelectData')) {
            return value.map((e) => e.value?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
          }
          return value.map((e) => e.toString()).where((s) => s.isNotEmpty).join(',');
        }
        if (value.runtimeType.toString().contains('SelectData')) {
          return value.value?.toString() ?? '';
        }
        return value.toString();

      default:
        // 其他类型直接转换为字符串
        return value.toString();
    }
  }

  /// 检查字符串是否是List的字符串表示（如"[orange]"）
  /// 用于检测和修复错误的数据转换
  static bool isListStringRepresentation(String str) {
    return str.startsWith('[') && str.endsWith(']');
  }

  /// 解析List字符串表示，提取实际的选项值
  /// 将"[orange,apple]"转换为"orange,apple"
  static String parseListStringRepresentation(String str) {
    if (!isListStringRepresentation(str)) return str;

    final listStr = str.substring(1, str.length - 1); // 去掉方括号
    if (listStr.isEmpty) return '';

    // 处理可能包含引号的情况
    final values = listStr.split(',').map((e) => e.trim()).toList();
    final cleanValues = values.map((e) {
      // 去掉可能的引号
      if ((e.startsWith("'") && e.endsWith("'")) || (e.startsWith('"') && e.endsWith('"'))) {
        return e.substring(1, e.length - 1);
      }
      return e;
    }).toList();

    return cleanValues.join(',');
  }

  /// 智能处理controller文本，自动检测和修复List字符串表示
  static String smartProcessControllerText(String controllerText, FormType fieldType) {
    if (controllerText.isEmpty) return controllerText;

    // 检查是否是List的字符串表示
    if (isListStringRepresentation(controllerText)) {
      return parseListStringRepresentation(controllerText);
    }

    return controllerText;
  }
}
