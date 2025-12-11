import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

/// ConfigForm 组件完整示例页面
/// 展示：核心功能、参数配置、事件处理、样式控制
/// 特别展示：上传组件默认值、单选组件默认值
class FormConfigExamplePage extends StatefulWidget {
  const FormConfigExamplePage({super.key});
  @override
  State<FormConfigExamplePage> createState() => _FormConfigExamplePageState();
}

class _FormConfigExamplePageState extends State<FormConfigExamplePage> {
  // 控制器：统一管理表单数据、校验、重置等
  late ConfigFormController _controller;
  // 当前表单数据（用于界面显示）
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _controller = ConfigFormController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 示例：根据性别动态显示「爱好（多选）」字段
  bool get _showHobbies => (_controller.getValue<String?>('gender') ?? 'male') == 'male';

  /// 表单配置：包含主要字段类型与参数示例
  List<FormConfig> get _configs => [
    // 单选组件（含默认值）
    FormConfig(
      type: FormType.radio,
      name: 'gender',
      label: '性别',
      required: true,
      // 默认选中「男」
      defaultValue: 'male',
      props: RadioProps<String>(
        options: const [
          SelectData(label: '男', value: 'male', data: '男性'),
          SelectData(label: '女', value: 'female', data: '女性'),
          SelectData(label: '其他', value: 'other', data: '其他'),
        ],
        onChanged: (val, data, full) {
          // 性别变化，触发重建以更新条件字段显示
          setState(() {});
        },
      ),
    ),

    // 文本输入（包含验证与属性示例）
    FormConfig(
      type: FormType.text,
      name: 'username',
      label: '用户名',
      required: true,
      defaultValue: 'admin_user',
      validator: (value) {
        final v = (value ?? '').toString();
        if (v.isEmpty) return '请输入用户名';
        if (v.length < 3) return '至少 3 个字符';
        return null;
      },
      props: const TextFieldProps(minLength: 3, maxLength: 20, keyboardType: TextInputType.text),
    ),

    // 数字输入
    FormConfig(type: FormType.number, name: 'price', label: '价格', required: true, defaultValue: 99.99, props: const NumberProps(minValue: 0, maxValue: 9999.99, decimalPlaces: 2)),

    // 整数输入
    FormConfig(type: FormType.integer, name: 'quantity', label: '数量', required: true, defaultValue: 1, props: const IntegerProps(minValue: 1, maxValue: 100)),

    // 多行文本
    FormConfig(type: FormType.textarea, name: 'description', label: '描述', required: false, defaultValue: '这是一个完整示例的说明文字', props: const TextareaProps(rows: 4, maxLength: 300)),

    // 多选（条件显示）
    FormConfig(
      type: FormType.checkbox,
      name: 'hobbies_checkbox',
      label: '爱好（多选）',
      required: false,
      isShow: _showHobbies,
      defaultValue: const ['reading', 'music'],
      props: CheckboxProps<String>(
        options: const [
          SelectData(label: '阅读', value: 'reading', data: '阅读'),
          SelectData(label: '音乐', value: 'music', data: '音乐'),
          SelectData(label: '运动', value: 'sports', data: '运动'),
          SelectData(label: '旅行', value: 'travel', data: '旅行'),
        ],
      ),
    ),

    // 下拉选择（含默认值示例）
    FormConfig(
      type: FormType.dropdown,
      name: 'city',
      label: '城市',
      required: true,
      defaultValue: const SelectData<String>(label: '北京', value: 'beijing', data: '北京市'),
      props: DropdownProps<String>(
        options: const [
          SelectData(label: '北京', value: 'beijing', data: '北京市'),
          SelectData(label: '上海', value: 'shanghai', data: '上海市'),
          SelectData(label: '深圳', value: 'shenzhen', data: '深圳市'),
        ],
      ),
    ),

    // 上传组件（含默认值）
    FormConfig(
      type: FormType.upload,
      name: 'attachments',
      label: '附件上传',
      required: false,
      // 默认值：模拟已上传成功的文件列表（网络文件）
      defaultValue: [
        FileUploadModel(
          name: '示例文件一.pdf',
          path: '/network/example-1.pdf',
          source: FileSource.network,
          status: UploadStatus.success,
          progress: 1.0,
          url: 'https://example.com/files/example-1.pdf',
          fileInfo: FileInfo(id: 1, fileName: '示例文件一.pdf', requestPath: '/files/example-1.pdf'),
        ),
        FileUploadModel(
          name: '示例图片二.jpg',
          path: '/network/example-2.jpg',
          source: FileSource.network,
          status: UploadStatus.success,
          progress: 1.0,
          url: 'https://example.com/files/example-2.jpg',
          fileInfo: FileInfo(id: 2, fileName: '示例图片二.jpg', requestPath: '/files/example-2.jpg'),
        ),
      ],
      props: UploadProps(
        maxFiles: 3,
        fileListType: FileListType.card,
        fileSource: FileSource.all,
        autoUpload: true,
        isRemoveFailFile: false,
        // 使用自定义上传（示例：模拟进度与成功返回）
        customUpload: (filePath, onProgress) async {
          for (int i = 0; i <= 100; i += 20) {
            await Future.delayed(const Duration(milliseconds: 120));
            onProgress(i / 100.0);
          }
          return FileUploadModel(
            name: filePath.split('/').last,
            path: filePath,
            source: FileSource.file,
            status: UploadStatus.success,
            progress: 1.0,
            url: 'https://example.com/uploads/${filePath.split('/').last}',
            fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: filePath.split('/').last, requestPath: '/uploads/${filePath.split('/').last}'),
          );
        },
        onFileChange: (current, selected, action) {
          // 同步到控制器数据
          _controller.setFieldValue('attachments', selected);
          // 更新页面展示
          setState(() {});
        },
      ),
    ),
  ];

  /// 表单数据变化回调：演示实时联动
  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
    // 当性别变化时，重新构建以应用条件显示
    if (data.containsKey('gender')) setState(() {});
  }

  /// 提交：验证后弹窗展示结果
  void _submit() {
    final isValid = _controller.validate();
    if (!isValid) {
      setState(() {});
      return;
    }
    final formData = _controller.formData;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('提交成功'),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: formData.entries.map((e) => Text('${e.key}: ${e.value}')).toList()),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
      ),
    );
  }

  /// 重置：清空数据并还原默认值
  void _reset() {
    _controller.reset();
    setState(() => _formData = {});
  }

  /// 清空：清除所有字段值
  void _clear() {
    _controller.clearAllFields();
    setState(() => _formData = {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 完整示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('示例说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• 展示核心功能：动态生成、验证、联动、条件显示\n• 参数配置示例：文本/数字/单选/多选/上传\n• 交互逻辑：实时 onChanged、提交/重置/清空\n• 特别演示：上传默认值、单选默认值', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // 动态配置表单
            ConfigForm(configs: _configs, controller: _controller, onChanged: _onFormChanged),

            const SizedBox(height: 16),

            // 操作按钮区
            Row(
              children: [
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text('提交'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _reset, child: const Text('重置')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _clear, child: const Text('清空')),
              ],
            ),

            const SizedBox(height: 16),

            // 实时数据展示
            const Text('实时表单数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_formData.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
