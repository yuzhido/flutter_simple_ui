import 'package:flutter_simple_ui/models/form_config.dart';
import 'package:flutter_simple_ui/models/form_type.dart';
import 'package:flutter_simple_ui/models/validator.dart';

class ValidationUtils {
  /// 获取字段的验证器
  static FormValidator? getValidator(FormConfig config) {
    // 如果字段不是必填的，不进行验证
    if (!config.required) {
      return null;
    }

    // 如果有自定义验证器，优先使用
    if (config.validator != null) {
      return config.validator;
    }

    // 否则使用默认验证规则
    return _getDefaultValidator(config);
  }

  /// 获取默认验证器
  static FormValidator? _getDefaultValidator(FormConfig config) {
    return (dynamic value) {
      // 必填验证（这里已经确保是必填字段）
      if (_isEmpty(value)) {
        return getDefaultErrorMessage(config);
      }

      // 根据字段类型进行额外验证
      switch (config.type) {
        case FormType.text:
          return _validateText(value, config);
        case FormType.textarea:
          return _validateTextarea(value, config);
        case FormType.number:
          return _validateNumber(value, config);
        case FormType.integer:
          return _validateInteger(value, config);
        case FormType.date:
          return _validateDate(value, config);
        default:
          return null;
      }
    };
  }

  /// 判断值是否为空
  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    return false;
  }

  /// 获取默认错误信息
  static String getDefaultErrorMessage(FormConfig config) {
    switch (config.type) {
      case FormType.dropdown:
      case FormType.select:
      case FormType.radio:
      case FormType.checkbox:
      case FormType.treeSelect:
        return '请选择${config.label}';
      case FormType.upload:
        return '请上传${config.label}';
      case FormType.text:
      case FormType.textarea:
      case FormType.number:
      case FormType.integer:
      case FormType.date:
      case FormType.time:
      case FormType.datetime:
        return '请输入${config.label}';
      default:
        return '${config.label}不能为空';
    }
  }

  /// 验证文本字段
  static String? _validateText(String value, FormConfig config) {
    // 获取文本字段属性
    final props = config.props as TextFieldProps?;

    // 长度验证
    if (props?.minLength != null && value.length < props!.minLength!) {
      return '${config.label}至少需要${props.minLength}个字符';
    }
    if (props?.maxLength != null && value.length > props!.maxLength!) {
      return '${config.label}不能超过${props.maxLength}个字符';
    }

    return null;
  }

  /// 验证多行文本字段
  static String? _validateTextarea(String value, FormConfig config) {
    // 获取多行文本字段属性
    final props = config.props as TextareaProps?;

    // 长度验证
    if (props?.minLength != null && value.length < props!.minLength!) {
      return '${config.label}至少需要${props.minLength}个字符';
    }
    if (props?.maxLength != null && value.length > props!.maxLength!) {
      return '${config.label}不能超过${props.maxLength}个字符';
    }

    return null;
  }

  /// 验证数字字段
  static String? _validateNumber(String value, FormConfig config) {
    final number = double.tryParse(value);
    if (number == null) {
      return '请输入有效的数字';
    }

    // 获取数字字段属性
    final props = config.props as NumberProps?;

    // 数值范围验证
    if (props?.minValue != null && number < props!.minValue!) {
      return '${config.label}不能小于${props.minValue}';
    }
    if (props?.maxValue != null && number > props!.maxValue!) {
      return '${config.label}不能大于${props.maxValue}';
    }

    // 小数位数验证
    if (props?.decimalPlaces != null) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > props!.decimalPlaces!) {
        return '${config.label}最多只能有${props.decimalPlaces}位小数';
      }
    }

    return null;
  }

  /// 验证整数字段
  static String? _validateInteger(String value, FormConfig config) {
    final integer = int.tryParse(value);
    if (integer == null) {
      return '请输入有效的整数';
    }

    // 获取整数字段属性
    final props = config.props as IntegerProps?;

    // 数值范围验证
    if (props?.minValue != null && integer < props!.minValue!) {
      return '${config.label}不能小于${props.minValue}';
    }
    if (props?.maxValue != null && integer > props!.maxValue!) {
      return '${config.label}不能大于${props.maxValue}';
    }

    return null;
  }

  /// 验证日期字段
  static String? _validateDate(String value, FormConfig config) {
    // 简单的日期格式验证
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return '请输入有效的日期格式 (YYYY-MM-DD)';
    }

    // 获取日期字段属性
    final props = config.props as DateProps?;

    // 验证日期是否有效
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      // 日期范围验证
      if (props?.minDate != null && date.isBefore(props!.minDate!)) {
        return '${config.label}不能早于${_formatDate(props.minDate!)}';
      }
      if (props?.maxDate != null && date.isAfter(props!.maxDate!)) {
        return '${config.label}不能晚于${_formatDate(props.maxDate!)}';
      }
    } catch (e) {
      return '请输入有效的日期';
    }

    return null;
  }

  /// 格式化日期
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
