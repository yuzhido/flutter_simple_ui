import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/models/validator.dart';

abstract class BaseFieldConfig {
  final String name;
  final String label;
  final bool required;
  final dynamic defaultValue;
  final FormValidator? validator;
  final bool isShow;
  final Key? key;

  const BaseFieldConfig({required this.name, required this.label, this.required = false, this.defaultValue, this.validator, this.isShow = true, this.key});
}

/// 统一的表单字段配置
class FormConfig<T> extends BaseFieldConfig {
  final FormType type;
  final T? props;
  const FormConfig({
    required this.type,
    required super.name,
    required super.label,
    super.required = false,
    super.defaultValue,
    super.validator,
    super.isShow = true,
    this.props,
    super.key,
  });
}

/// 文本字段配置属性
class TextFieldProps {
  final int? minLength;
  final int? maxLength;
  final TextInputType? keyboardType; // 键盘类型
  final List<TextInputFormatter>? inputFormatters; // 输入格式化器
  final void Function(String val)? onChanged;

  const TextFieldProps({this.minLength, this.maxLength, this.keyboardType, this.inputFormatters, this.onChanged});
}

/// 多行文本字段配置
class TextareaProps {
  final int? minLength;
  final int? maxLength;
  final int? rows;
  final void Function(String val)? onChanged;
  const TextareaProps({this.minLength, this.maxLength, this.rows = 4, this.onChanged});
}

/// 数字字段配置
class NumberProps {
  final double? minValue;
  final double? maxValue;
  final int? decimalPlaces;
  final void Function(double val)? onChanged;

  const NumberProps({this.minValue, this.maxValue, this.decimalPlaces, this.onChanged});
}

/// 整数字段配置
class IntegerProps {
  final int? minValue;
  final int? maxValue;
  final void Function(int val)? onChanged;

  const IntegerProps({this.minValue, this.maxValue, this.onChanged});
}

/// 日期字段配置
class DateProps {
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? format;
  final void Function(String val)? onChanged;

  const DateProps({this.minDate, this.maxDate, this.format = 'YYYY-MM-DD', this.onChanged});
}

/// 时间字段配置
class TimeProps {
  final String? format;
  final void Function(String val)? onChanged;

  const TimeProps({this.format = 'HH:mm', this.onChanged});
}

/// 日期时间字段配置
class DateTimeProps {
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? format;
  final void Function(String val)? onChanged;

  const DateTimeProps({this.minDate, this.maxDate, this.format = 'YYYY-MM-DD HH:mm', this.onChanged});
}

/// 单选字段配置
class RadioProps<T> {
  final List<SelectData<T>> options;
  // 单选回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onChanged;
  const RadioProps({required this.options, this.onChanged});
}

/// 多选字段配置
class CheckboxProps<T> {
  final List<SelectData<T>> options;
  // 多选回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onChanged;
  const CheckboxProps({required this.options, this.onChanged});
}

/// 下拉选择字段配置
class SelectProps<T> {
  final List<SelectData<T>> options;
  final bool multiple;
  final bool searchable;
  // 单选回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;
  const SelectProps({required this.options, this.multiple = false, this.searchable = false, this.onSingleChanged, this.onMultipleChanged});
}

/// 自定义下拉选择字段配置（基于 DropdownChoose）
class DropdownProps<T> {
  // 选项（本地）
  final List<SelectData<T>> options;
  // 是否多选
  final bool multiple;
  // 是否可过滤（本地）
  final bool filterable;
  // 是否远程搜索
  final bool remote;
  // 是否总是刷新数据（仅在remote为true时有效）
  final bool alwaysRefresh;
  // 远程搜索函数
  final Future<List<SelectData<T>>> Function(String)? remoteSearch;
  // 是否显示新增按钮
  final bool showAdd;
  // 新增回调
  final Future<bool?> Function(String)? onAdd;
  // 占位提示
  final String tips;
  // 单选回调
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选回调
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;

  const DropdownProps({
    this.options = const [],
    this.multiple = false,
    this.alwaysRefresh = false,
    this.filterable = false,
    this.remote = false,
    this.remoteSearch,
    this.showAdd = false,
    this.onAdd,
    this.tips = '',
    this.onSingleChanged,
    this.onMultipleChanged,
  });
}

/// 文件上传字段配置
class UploadProps {
  final List<String>? allowedTypes;
  final int? maxFileSize;
  final int? maxFiles;
  final String? uploadUrl;
  // 上传行为与展示
  final FileListType fileListType;
  final FileSource fileSource;
  final bool autoUpload;
  final bool isRemoveFailFile;
  // 自定义上传
  final Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)? customUpload;

  /// 自定义上传区域内容（当 fileListType 为 custom 时使用）
  final Widget Function(VoidCallback onTap)? customAreaContent;

  /// 参数3: 操作类型 ('add' 或 'remove')
  final Function(FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action)? onFileChange;

  /// 上传进度回调
  final Function(FileUploadModel file, double progress)? onUploadProgress;

  /// 上传成功回调
  final Function(FileUploadModel file)? onUploadSuccess;

  /// 上传失败回调
  final Function(FileUploadModel file, String error)? onUploadFailed;

  const UploadProps({
    this.allowedTypes,
    this.maxFileSize,
    this.maxFiles = -1,
    this.uploadUrl,
    this.fileListType = FileListType.card,
    this.fileSource = FileSource.all,
    this.autoUpload = true,
    this.isRemoveFailFile = false,
    this.customUpload,
    this.customAreaContent,
    this.onFileChange,
    this.onUploadProgress,
    this.onUploadSuccess,
    this.onUploadFailed,
  });
}

/// 树选择字段配置
class TreeSelectProps<T> {
  final List<SelectData<T>> options;
  final bool multiple;
  final bool checkable;
  // 顶部title
  final String title;
  // 顶部提示
  final String hintText;
  // 单选模式回调 - 参数: (选中的value值, 选中的data值, 选中的完整数据)
  final void Function(dynamic, T, SelectData<T>)? onSingleChanged;
  // 多选模式回调 - 参数: (选中的value值列表, 选中的data值列表, 选中的完整数据列表)
  final void Function(List<dynamic>, List<T>, List<SelectData<T>>)? onMultipleChanged;
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

  const TreeSelectProps({
    required this.options,
    this.multiple = false,
    this.checkable = false,
    this.title = '树形选择器',
    this.hintText = '请输入关键字搜索',
    this.onSingleChanged,
    this.onMultipleChanged,
    this.remoteFetch,
    this.remote = false,
    this.filterable = false,
    this.lazyLoad = false,
    this.lazyLoadFetch,
    this.isCacheData = true,
  });
}

/// 自定义字段配置：要求提供 contentBuilder
class CustomProps {
  final ContentBuilder contentBuilder;
  const CustomProps({required this.contentBuilder});
}
