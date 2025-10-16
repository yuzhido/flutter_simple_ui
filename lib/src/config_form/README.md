# ConfigForm 配置表单组件

ConfigForm 是一个基于配置的动态表单组件，支持多种表单字段类型，提供统一的数据管理和验证机制。

## 示例展示

<img src="Snipaste_2025-10-15_13-32-43.png" width="300" alt="ConfigForm 示例" />

## 特性

- **多种字段类型**：支持文本、数字、日期、下拉选择、树形选择、文件上传等 14 种字段类型
- **动态表单**：基于配置动态生成表单，支持字段的显示/隐藏控制
- **数据验证**：内置验证机制，支持自定义验证器
- **统一管理**：通过 ConfigFormController 统一管理表单数据和状态
- **实时响应**：支持表单数据变化的实时监听和响应
- **灵活配置**：每种字段类型都有丰富的配置选项

## 基本用法

### 简单示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class BasicConfigFormExample extends StatefulWidget {
  @override
  _BasicConfigFormExampleState createState() => _BasicConfigFormExampleState();
}

class _BasicConfigFormExampleState extends State<BasicConfigFormExample> {
  late ConfigFormController _controller;
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _controller = ConfigFormController();
  }

  // 表单配置
  List<FormConfig> get _formConfigs => [
    FormConfig(
      type: FormType.text,
      name: 'username',
      label: '用户名',
      required: true,
      defaultValue: 'admin',
      props: const TextFieldProps(
        minLength: 3,
        maxLength: 20,
        keyboardType: TextInputType.text,
      ),
    ),
    FormConfig(
      type: FormType.dropdown,
      name: 'gender',
      label: '性别',
      required: true,
      props: DropdownProps<String>(
        options: const [
          SelectData(label: '男', value: 'male', data: '男性'),
          SelectData(label: '女', value: 'female', data: '女性'),
        ],
      ),
    ),
    FormConfig(
      type: FormType.number,
      name: 'price',
      label: '价格',
      required: true,
      defaultValue: 99.99,
      props: const NumberProps(
        minValue: 0,
        maxValue: 9999.99,
        decimalPlaces: 2,
      ),
    ),
  ];

  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }

  void _submitForm() {
    if (_controller.validate()) {
      final formData = _controller.formData;
      print('提交表单数据: $formData');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ConfigForm(
              configs: _formConfigs,
              controller: _controller,
              onChanged: _onFormChanged,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('提交表单'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 支持的字段类型

### 1. 文本输入 (FormType.text)

```dart
FormConfig(
  type: FormType.text,
  name: 'username',
  label: '用户名',
  required: true,
  validator: (value) {
    if (value?.toString().contains(RegExp(r'[!@#$%^&*()]')) == true) {
      return '用户名不能包含特殊字符';
    }
    return null;
  },
  props: const TextFieldProps(
    minLength: 3,
    maxLength: 20,
    keyboardType: TextInputType.text,
  ),
)
```

### 2. 数字输入 (FormType.number)

```dart
FormConfig(
  type: FormType.number,
  name: 'price',
  label: '价格',
  required: true,
  props: const NumberProps(
    minValue: 0,
    maxValue: 9999.99,
    decimalPlaces: 2,
  ),
)
```

### 3. 整数输入 (FormType.integer)

```dart
FormConfig(
  type: FormType.integer,
  name: 'quantity',
  label: '数量',
  required: true,
  props: const IntegerProps(
    minValue: 1,
    maxValue: 100,
  ),
)
```

### 4. 多行文本 (FormType.textarea)

```dart
FormConfig(
  type: FormType.textarea,
  name: 'description',
  label: '描述',
  required: false,
  props: const TextareaProps(
    rows: 4,
    maxLength: 500,
  ),
)
```

### 5. 下拉选择 (FormType.dropdown)

```dart
FormConfig(
  type: FormType.dropdown,
  name: 'city',
  label: '城市',
  required: true,
  props: DropdownProps<String>(
    options: const [
      SelectData(label: '北京', value: 'beijing', data: '北京市'),
      SelectData(label: '上海', value: 'shanghai', data: '上海市'),
    ],
    multiple: false, // 单选
    filterable: true, // 可过滤
  ),
)
```

### 6. 多选框 (FormType.checkbox)

```dart
FormConfig(
  type: FormType.checkbox,
  name: 'hobbies',
  label: '爱好',
  required: false,
  props: CheckboxProps<String>(
    options: const [
      SelectData(label: '阅读', value: 'reading', data: '阅读'),
      SelectData(label: '音乐', value: 'music', data: '音乐'),
      SelectData(label: '运动', value: 'sports', data: '运动'),
    ],
  ),
)
```

### 7. 树形选择 (FormType.treeSelect)

```dart
FormConfig(
  type: FormType.treeSelect,
  name: 'department',
  label: '部门选择',
  required: false,
  props: TreeSelectProps<String>(
    options: treeData,
    title: '选择部门',
    hintText: '请选择部门',
    multiple: false,
    remote: true,
    remoteFetch: _fetchDepartments,
    lazyLoad: true,
    lazyLoadFetch: _lazyLoadDepartments,
  ),
)
```

### 8. 日期选择 (FormType.date)

```dart
FormConfig(
  type: FormType.date,
  name: 'birthday',
  label: '生日',
  required: false,
  props: const DateProps(
    format: 'YYYY-MM-DD',
  ),
)
```

### 9. 时间选择 (FormType.time)

```dart
FormConfig(
  type: FormType.time,
  name: 'meeting_time',
  label: '会议时间',
  required: false,
  props: const TimeProps(
    format: 'HH:mm',
  ),
)
```

### 10. 日期时间选择 (FormType.datetime)

```dart
FormConfig(
  type: FormType.datetime,
  name: 'created_at',
  label: '创建时间',
  required: false,
  props: const DateTimeProps(
    format: 'YYYY-MM-DD HH:mm',
  ),
)
```

### 11. 文件上传 (FormType.upload)

```dart
FormConfig(
  type: FormType.upload,
  name: 'attachments',
  label: '附件上传',
  required: false,
  props: UploadProps(
    maxFiles: 3,
    fileListType: FileListType.card,
    fileSource: FileSource.all,
    autoUpload: true,
    customUpload: _customUploadFunction,
    onFileChange: (current, selected, action) {
      print('文件变化: $action');
    },
  ),
)
```

## 动态表单控制

### 条件显示字段

```dart
class DynamicFormExample extends StatefulWidget {
  @override
  _DynamicFormExampleState createState() => _DynamicFormExampleState();
}

class _DynamicFormExampleState extends State<DynamicFormExample> {
  late ConfigFormController _controller;

  List<FormConfig> get _formConfigs {
    // 根据性别字段的值决定是否显示爱好字段
    final genderValue = _controller.getValue<String?>('gender');
    final shouldShowHobbies = genderValue == 'male';

    return [
      FormConfig(
        type: FormType.dropdown,
        name: 'gender',
        label: '性别',
        required: true,
        props: DropdownProps<String>(
          options: const [
            SelectData(label: '男', value: 'male', data: '男性'),
            SelectData(label: '女', value: 'female', data: '女性'),
          ],
        ),
      ),
      FormConfig(
        type: FormType.checkbox,
        name: 'hobbies',
        label: '爱好',
        required: false,
        isShow: shouldShowHobbies, // 动态控制显示
        props: CheckboxProps<String>(
          options: const [
            SelectData(label: '阅读', value: 'reading', data: '阅读'),
            SelectData(label: '音乐', value: 'music', data: '音乐'),
          ],
        ),
      ),
    ];
  }

  void _onFormChanged(Map<String, dynamic> data) {
    // 当性别字段变化时，重新构建表单
    if (data.containsKey('gender')) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfigForm(
      configs: _formConfigs,
      controller: _controller,
      onChanged: _onFormChanged,
    );
  }
}
```

## ConfigFormController API

### 主要方法

```dart
// 创建控制器
final controller = ConfigFormController();

// 验证表单
bool isValid = controller.validate();

// 获取表单数据
Map<String, dynamic> formData = controller.formData;

// 设置字段值
controller.setFieldValue('username', 'new_value');

// 批量设置字段值
controller.setFieldValues({
  'username': 'admin',
  'gender': 'male',
});

// 获取字段值
String? username = controller.getValue<String>('username');

// 清空字段
controller.clearFieldValue('username');

// 清空所有字段
controller.clearAllFields();

// 重置表单（恢复默认值）
controller.reset();

// 设置字段错误
controller.setFieldError('username', '用户名已存在');

// 清除字段错误
controller.clearFieldError('username');
```

## 自定义验证器

```dart
FormConfig(
  type: FormType.text,
  name: 'email',
  label: '邮箱',
  required: true,
  validator: (value) {
    final email = value?.toString() ?? '';
    if (email.isEmpty) {
      return '请输入邮箱';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return '请输入有效的邮箱地址';
    }
    return null; // 验证通过
  },
)
```

## 远程数据加载

### 下拉选择远程搜索

```dart
FormConfig(
  type: FormType.dropdown,
  name: 'city',
  label: '城市',
  props: DropdownProps<String>(
    remote: true,
    remoteSearch: (keyword) async {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 500));
      return [
        SelectData(label: '北京', value: 'beijing', data: '北京市'),
        SelectData(label: '上海', value: 'shanghai', data: '上海市'),
      ].where((item) =>
        item.label.contains(keyword)
      ).toList();
    },
  ),
)
```

### 树形选择懒加载

```dart
FormConfig(
  type: FormType.treeSelect,
  name: 'department',
  label: '部门',
  props: TreeSelectProps<String>(
    lazyLoad: true,
    lazyLoadFetch: (parentNode) async {
      // 根据父节点加载子节点
      final children = await _loadDepartmentChildren(parentNode.value);
      return children;
    },
  ),
)
```

## 文件上传配置

### 自定义上传函数

```dart
Future<FileUploadModel?> _customUploadFunction(
  String filePath,
  Function(double) onProgress
) async {
  try {
    // 模拟上传进度
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 100));
      onProgress(i / 100.0);
    }

    // 返回上传结果
    return FileUploadModel(
      name: filePath.split('/').last,
      path: filePath,
      status: UploadStatus.success,
      fileInfo: FileInfo(
        id: DateTime.now().millisecondsSinceEpoch,
        fileName: filePath.split('/').last,
        requestPath: '/uploads/${filePath.split('/').last}',
      ),
    );
  } catch (e) {
    return null;
  }
}
```

## 使用场景

- **用户注册/登录表单**：用户信息收集
- **设置页面**：应用配置管理
- **数据录入**：业务数据的结构化录入
- **搜索筛选**：复杂的搜索条件构建
- **内容管理**：文章、产品等内容的编辑
- **审批流程**：工作流中的表单填写

## 最佳实践

### 1. 表单配置管理

```dart
class FormConfigManager {
  static List<FormConfig> getUserFormConfigs() {
    return [
      FormConfig(
        type: FormType.text,
        name: 'username',
        label: '用户名',
        required: true,
        props: const TextFieldProps(minLength: 3, maxLength: 20),
      ),
      // ... 其他配置
    ];
  }
}
```

### 2. 数据持久化

```dart
class FormDataManager {
  static const String _storageKey = 'form_data';

  static Future<void> saveFormData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>> loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_storageKey);
    if (dataStr != null) {
      return jsonDecode(dataStr);
    }
    return {};
  }
}
```

### 3. 错误处理

```dart
void _handleFormSubmit() async {
  try {
    if (!_controller.validate()) {
      _showErrorMessage('请检查表单输入');
      return;
    }

    final formData = _controller.formData;
    await _submitToServer(formData);
    _showSuccessMessage('提交成功');
  } catch (e) {
    _showErrorMessage('提交失败: $e');
  }
}
```

## 注意事项

1. **性能优化**：对于大型表单，考虑使用 `ListView.builder` 来优化渲染性能
2. **内存管理**：及时释放 ConfigFormController 资源
3. **数据验证**：重要数据建议在客户端和服务端都进行验证
4. **用户体验**：为长时间操作（如文件上传）提供进度指示
5. **错误处理**：提供清晰的错误提示和恢复机制

## 常见问题

### Q: 如何实现字段间的联动？

A: 使用 `onChanged` 回调监听数据变化，在回调中调用 `setState()` 重新构建表单配置。

### Q: 如何自定义字段样式？

A: 使用 `FormType.custom` 类型，通过 `CustomProps` 的 `contentBuilder` 自定义字段 UI。

### Q: 如何处理复杂的验证逻辑？

A: 在 `FormConfig` 中使用自定义 `validator` 函数，可以访问整个表单数据进行复杂验证。

### Q: 如何实现表单数据的自动保存？

A: 在 `onChanged` 回调中实现防抖逻辑，定期保存表单数据到本地存储。
