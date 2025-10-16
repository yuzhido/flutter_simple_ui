// 公有数据结构
class SelectData<T> {
  final String label;
  final dynamic value;
  final T data;
  final bool disabled;
  // 新增的属性
  final List<SelectData<T>>? children;
  final bool hasChildren;

  const SelectData({required this.label, required this.value, this.disabled = false, this.hasChildren = false, this.children, required this.data});

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'hasChildren': hasChildren, 'disabled': disabled, 'children': children?.map((child) => child.toJson()).toList(), 'data': data};
  }

  /// 从JSON创建实例
  factory SelectData.fromJson(Map<String, dynamic> json) {
    return SelectData<T>(
      label: json['label'] as String,
      value: json['value'],
      disabled: json['disabled'] as bool? ?? false,
      hasChildren: json['hasChildren'] as bool? ?? false,
      children: json['children'] != null ? (json['children'] as List).map((childJson) => SelectData<T>.fromJson(childJson as Map<String, dynamic>)).toList() : null,
      data: json['data'] as T,
    );
  }

  /// 从JSON列表创建SelectData列表
  static List<SelectData<T>> fromJsonList<T>(List<dynamic> jsonList) {
    return jsonList.map((json) => SelectData<T>.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// 将SelectData列表转换为JSON列表
  static List<Map<String, dynamic>> toJsonList<T>(List<SelectData<T>> dataList) {
    return dataList.map((data) => data.toJson()).toList();
  }

  @override
  String toString() {
    return 'SelectData(label: $label, value: $value, hasChildren: $hasChildren, disabled: $disabled, children: ${children?.length}, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectData<T> && other.label == label && other.value == value && other.hasChildren == hasChildren && other.disabled == disabled && other.data == data;
  }

  @override
  int get hashCode {
    return label.hashCode ^ value.hashCode ^ hasChildren.hashCode ^ data.hashCode;
  }
}
