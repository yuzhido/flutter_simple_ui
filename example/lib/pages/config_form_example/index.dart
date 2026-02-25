import 'package:example/api/address_api.dart';
import 'package:example/api/hobby_api.dart';
import 'package:example/api/user_api.dart';
import 'package:example/api/models/user.dart';
import 'package:example/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class ConfigFormExamplePage extends StatefulWidget {
  const ConfigFormExamplePage({super.key});
  @override
  State<ConfigFormExamplePage> createState() => _ConfigFormExamplePageState();
}

class _ConfigFormExamplePageState extends State<ConfigFormExamplePage> {
  late ConfigFormController _controller;
  Map<String, dynamic> _formData = {};
  final String _uploadStatus = '等待上传...';
  final AddressApi _addressApi = AddressApi();

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

  // 真实接口上传函数
  Future<FileUploadModel?> _realUploadFunction(String filePath, Function(double) onProgress) async {
    try {
      final dio = Dio();

      // 准备FormData
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last)});

      // 发送请求
      final response = await dio.request(
        '${Config.baseUrl}/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST', headers: {'Authorization': 'Bearer your-token-here'}),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return FileUploadModel(
          name: filePath.split('/').last,
          path: filePath,
          source: FileSource.file,
          status: UploadStatus.success,
          progress: 1.0,
          fileSize: responseData['size'] ?? 0,
          fileSizeInfo: _formatFileSize(responseData['size'] ?? 0),
          url: responseData['url'] ?? '',
          fileInfo: FileInfo(
            id: responseData['id'] ?? DateTime.now().millisecondsSinceEpoch,
            fileName: responseData['filename'] ?? filePath.split('/').last,
            requestPath: responseData['path'] ?? '',
          ),
        );
      }
      return null;
    } catch (e) {
      print('上传失败: $e');
      return null;
    }
  }

  // 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // 表单配置
  List<FormConfig> get _formConfigs {
    // 检查性别字段的值，决定是否显示爱好字段
    final genderValue = _controller.getValue<String?>('gender');
    final shouldShowHobbies = genderValue == 'male';

    return [
      // 用户选择（使用真实API远程搜索）
      FormConfig(
        type: FormType.dropdown,
        name: 'user_remote',
        label: '用户选择（远程搜索）',
        required: true,
        validator: (value) {
          if (value == null) {
            return '请选择一个用户';
          }
          return null;
        },
        props: DropdownProps<User>(
          options: const [], // 初始为空，通过远程搜索获取
          remote: true, // 启用远程搜索
          remoteSearch: _searchUsers, // 使用我们定义的用户搜索方法
          showClear: true, // 启用清除功能
          onClear: () {
            print('用户字段被清除，可以在这里处理级联逻辑');
          },
          tips: '请输入用户姓名搜索',
        ),
      ),
      // 自定义下拉选择爱好（使用真实API远程搜索）
      FormConfig(
        type: FormType.dropdown,
        name: 'hobby_remote',
        label: '爱好选择（远程搜索）',
        required: true,
        validator: (value) {
          if (value == null) {
            return '请选择一个爱好';
          }
          return null;
        },
        props: DropdownProps<String>(
          options: const [], // 初始为空，通过远程搜索获取
          remote: true, // 启用远程搜索
          remoteSearch: _searchHobbies, // 使用我们定义的爱好搜索方法
          showClear: true, // 启用清除功能
          tips: '搜索爱好...',
        ),
      ),
      // 真实API地址选择示例 - 省份选择（懒加载模式）
      FormConfig(
        type: FormType.treeSelect,
        name: 'province',
        label: '省份选择（真实API - 懒加载）',
        required: false,
        props: TreeSelectProps<String>(
          options: const [],
          title: '选择省份',
          hintText: '点击展开加载省份数据',
          remote: true,
          remoteFetch: _fetchProvincesForSearch,
          lazyLoad: true,
          lazyLoadFetch: _fetchProvincesLazyLoad,
          isCacheData: true,
          onSingleChanged: (value, data, selectedData) {
            print('省份选择: $value -> ${selectedData.label}');
            // 省份改变时，清空城市和区县选择
            _controller.setFieldValue('city_real', null);
            _controller.setFieldValue('district_real', null);
          },
        ),
      ),
      // 真实API地址选择示例 - 城市选择
      FormConfig(
        type: FormType.treeSelect,
        name: 'city_real',
        label: '城市选择（真实API）',
        required: false,
        props: TreeSelectProps<String>(
          options: const [],
          title: '选择城市',
          hintText: '请先选择省份，然后搜索城市',
          remote: true,
          remoteFetch: _fetchCities,
          isCacheData: true,
          onSingleChanged: (value, data, selectedData) {
            print('城市选择: $value -> ${selectedData.label}');
            // 城市改变时，清空区县选择
            _controller.setFieldValue('district_real', null);
          },
        ),
      ),
      // 真实API地址选择示例 - 区县选择
      FormConfig(
        type: FormType.treeSelect,
        name: 'district_real',
        label: '区县选择（真实API）',
        required: false,
        props: TreeSelectProps<String>(
          options: const [],
          title: '选择区县',
          hintText: '请先选择城市，然后搜索区县',
          remote: true,
          remoteFetch: _fetchDistricts,
          isCacheData: true,
          onSingleChanged: (value, data, selectedData) {
            print('区县选择: $value -> ${selectedData.label}');
          },
        ),
      ),
      // 真实API地址搜索示例
      FormConfig(
        type: FormType.treeSelect,
        name: 'address_search',
        label: '地址搜索（真实API）',
        required: false,
        props: TreeSelectProps<String>(
          options: const [],
          title: '搜索地址',
          hintText: '输入关键字搜索全国地址',
          remote: true,
          remoteFetch: _searchAddresses,
          isCacheData: false, // 搜索结果不缓存
          onSingleChanged: (value, data, selectedData) {
            print('地址搜索选择: $value -> ${selectedData.label}');
          },
        ),
      ),
      // 自定义上传区域示例（真实接口）
      FormConfig(
        type: FormType.upload,
        name: 'customAreaUpload',
        label: '自定义上传区域（真实接口）',
        required: false,
        props: UploadProps(
          maxFiles: 3,
          fileListType: FileListType.custom,
          fileSource: FileSource.all,
          autoUpload: true,
          isRemoveFailFile: false,
          // 使用真实接口上传
          customUpload: _realUploadFunction,
          // 自定义上传区域内容
          customAreaContent: (onTap) => GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade400),
                  const SizedBox(height: 8),
                  Text(
                    '拖拽文件到此处或点击选择',
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text('支持多种文件格式，最多3个文件', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ),
          // 上传进度回调
          onUploadProgress: (file, progress) {
            print('文件 ${file.name} 上传进度: ${(progress * 100).toStringAsFixed(1)}%');
          },
          // 上传成功回调
          onUploadSuccess: (file) {
            print('文件 ${file.name} 上传成功');
          },
          // 上传失败回调
          onUploadFailed: (file, error) {
            print('文件 ${file.name} 上传失败: $error');
          },
        ),
      ),
      // 真实接口文件上传示例
      FormConfig(
        type: FormType.upload,
        name: 'realUploadFile',
        label: '真实接口文件上传',
        required: true,
        validator: (value) {
          if (value == null || (value is List && value.isEmpty)) {
            return '请上传文件';
          }
          return null;
        },
        props: UploadProps(
          maxFiles: 2,
          fileListType: FileListType.card,
          fileSource: FileSource.all,
          autoUpload: true,
          isRemoveFailFile: false,
          // 使用真实接口上传
          customUpload: _realUploadFunction,

          // 上传进度回调
        ),
      ),
      // 文件上传
      FormConfig(
        type: FormType.upload,
        name: 'fileInfo',
        label: '模拟文件上传',
        required: true,
        validator: (value) {
          // 自定义验证器：检查是否上传了文件
          if (value == null || (value is List && value.isEmpty)) {
            return '请上传文件';
          }
          return null; // 验证通过
        },
        props: UploadProps(
          maxFiles: 3, // 最多上传3个文件
          fileListType: FileListType.card, // 卡片样式
          fileSource: FileSource.all, // 允许所有类型文件
          autoUpload: true, // 自动上传
          isRemoveFailFile: false, // 上传失败时不自动移除
          // 自定义上传函数
          customUpload: (filePath, onProgress) async {
            // 模拟上传过程
            print('开始上传文件: $filePath');

            // 模拟上传进度
            for (int i = 0; i <= 100; i += 10) {
              await Future.delayed(Duration(milliseconds: 100));
              onProgress(i / 100.0);
            }

            // 模拟上传成功，返回文件信息
            return FileUploadModel(
              name: filePath.split('/').last,
              path: filePath,
              source: FileSource.file,
              status: UploadStatus.success,
              progress: 1.0,
              fileSize: 1024 * 1024, // 1MB
              fileSizeInfo: '1.0MB',
              url: 'https://example.com/uploads/${filePath.split('/').last}',
              fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: filePath.split('/').last, requestPath: '/uploads/${filePath.split('/').last}'),
            );
          },
          // 文件变化回调
          onFileChange: (current, selected, action) {
            print('文件变化: $action, 当前文件: ${current.name}, 总文件数: ${selected.length}');
          },
        ),
      ),
      FormConfig(
        type: FormType.text,
        name: 'username',
        label: '用户名',
        required: true,
        defaultValue: 'admin',
        validator: (value) {
          // 自定义验证器示例：用户名不能包含特殊字符
          final username = value?.toString() ?? '';
          if (username.isEmpty) {
            return '请输入用户名';
          }
          if (username.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
            return '用户名不能包含特殊字符';
          }
          return null; // 验证通过
        },
        props: const TextFieldProps(minLength: 3, maxLength: 20, keyboardType: TextInputType.text),
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
            SelectData(label: '其他', value: 'other', data: '其他'),
          ],
        ),
      ),
      FormConfig(
        type: FormType.dropdown,
        name: 'hobbies',
        label: '爱好',
        required: true,
        isShow: shouldShowHobbies, // 根据性别字段的值动态控制显示
        props: DropdownProps<String>(
          multiple: true,
          options: const [
            SelectData(label: '阅读', value: 'reading', data: '阅读'),
            SelectData(label: '音乐', value: 'music', data: '音乐'),
            SelectData(label: '运动', value: 'sports', data: '运动'),
            SelectData(label: '旅行', value: 'travel', data: '旅行'),
            SelectData(label: '摄影', value: 'photography', data: '摄影'),
          ],
        ),
      ),

      // 数字输入
      FormConfig(
        type: FormType.number,
        name: 'price',
        label: '价格',
        required: true,
        defaultValue: 99.99,
        validator: (value) {
          // 自定义验证器示例：价格验证
          final priceStr = value?.toString() ?? '';
          if (priceStr.isEmpty) {
            return '请输入价格';
          }
          final price = double.tryParse(priceStr);
          if (price == null) {
            return '请输入有效的价格';
          }
          if (price > 5000) {
            return '价格不能超过5000元';
          }
          return null; // 验证通过
        },
        props: const NumberProps(minValue: 0, maxValue: 9999.99, decimalPlaces: 2),
      ),

      // 整数输入（使用默认验证）
      FormConfig(type: FormType.integer, name: 'quantity', label: '数量', required: true, defaultValue: 1, props: const IntegerProps(minValue: 1, maxValue: 100)),

      // 多行文本（非必填，不会进行验证）
      FormConfig(type: FormType.textarea, name: 'description', label: '描述', required: false, defaultValue: '这是一个示例描述', props: const TextareaProps(rows: 4, maxLength: 500)),

      // 多选
      FormConfig(
        type: FormType.checkbox,
        name: 'hobbies_checkbox',
        label: '爱好（多选）',
        required: false,
        defaultValue: ['reading', 'music'],
        isShow: shouldShowHobbies, // 根据性别字段的值动态控制显示
        props: CheckboxProps<String>(
          options: const [
            SelectData(label: '阅读', value: 'reading', data: '阅读'),
            SelectData(label: '音乐', value: 'music', data: '音乐'),
            SelectData(label: '运动', value: 'sports', data: '运动'),
            SelectData(label: '旅行', value: 'travel', data: '旅行'),
            SelectData(label: '摄影', value: 'photography', data: '摄影'),
          ],
        ),
      ),

      // 下拉选择（使用默认验证）
      FormConfig(
        type: FormType.dropdown,
        name: 'city',
        label: '城市',
        required: true,
        defaultValue: SelectData(label: '北京', value: 'beijing', data: '北京市'),
        props: DropdownProps(
          options: const [
            SelectData<String>(label: '北京', value: 'beijing', data: '北京市'),
            SelectData<String>(label: '上海', value: 'shanghai', data: '上海市'),
            SelectData<String>(label: '广州', value: 'guangzhou', data: '广州市'),
            SelectData<String>(label: '深圳', value: 'shenzhen', data: '深圳市'),
            SelectData<String>(label: '杭州', value: 'hangzhou', data: '杭州市'),
          ],
        ),
      ),

      // 日期选择
      FormConfig(
        type: FormType.date,
        name: 'birthday',
        label: '生日',
        required: false,
        defaultValue: '1990-01-01',
        props: const DateProps(format: 'YYYY-MM-DD'),
      ),

      // 时间选择
      FormConfig(
        type: FormType.time,
        name: 'meeting_time',
        label: '会议时间',
        required: false,
        defaultValue: '14:30',
        props: const TimeProps(format: 'HH:mm'),
      ),

      // 日期时间选择
      FormConfig(
        type: FormType.datetime,
        name: 'created_at',
        label: '创建时间',
        required: false,
        defaultValue: '2024-01-01 10:00',
        props: const DateTimeProps(format: 'YYYY-MM-DD HH:mm'),
      ),
    ];
  }

  // 表单数据变化回调
  void _onFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
    print('表单数据变化: $data');

    // 如果性别字段发生变化，需要重新构建表单以更新爱好字段的显示状态
    if (data.containsKey('gender')) {
      // 性别字段变化，重新构建表单
      setState(() {});
    }
  }

  // 提交表单
  void _submitForm() {
    // 进行表单验证（现在不需要传参了！）
    final isValid = _controller.validate();
    setState(() {});
    if (!isValid) return;

    // 验证通过，显示提交结果
    final formData = _controller.formData;
    print('提交表单数据: $formData');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('表单提交成功'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('提交的数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...formData.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${entry.key}: ${entry.value}'))),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  // 重置表单
  void _resetForm() {
    _controller.reset();
    setState(() {
      _formData = {};
    });
  }

  // 清除表单
  void _clearForm() {
    _controller.clearAllFields();
    setState(() {
      _formData = {};
    });
  }

  // 设置默认值
  void _setDefaultValues() {
    final defaultValues = {
      'username': 'test_user',
      'gender': 'male',
      'hobbies': ['reading', 'music'],
      'price': 199.99,
      'quantity': 5,
      'description': '这是设置的默认描述',
      'city': 'beijing',
      'birthday': '1995-05-15',
      'meeting_time': '09:30',
      'created_at': '2024-12-01 15:30',
    };
    _controller.setFieldValues(defaultValues);
    setState(() {
      _formData = _controller.formData;
    });
  }

  // 查看表单数据
  void _viewFormData() {
    final formData = _controller.formData;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前表单数据'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('当前数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...formData.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${entry.key}: ${entry.value}'))),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  // 真实API方法：获取省份列表（用于搜索）
  Future<List<SelectData<String>>> _fetchProvincesForSearch(String keyword) async {
    await Future.delayed(Duration(seconds: 2));
    try {
      print('搜索省份，关键字: $keyword');

      if (keyword.isEmpty) {
        // 如果没有关键字，返回顶级省份数据
        final provinces = await _addressApi.getProvinces();
        return provinces.map((province) => SelectData<String>(label: province.name, value: province.id ?? '', data: province.id ?? '', hasChildren: province.hasChildren)).toList();
      } else {
        // 使用搜索接口
        final searchResponse = await _addressApi.searchAddresses(keyword: keyword);
        return searchResponse.list
            .map((address) => SelectData<String>(label: address.name, value: address.id ?? '', data: address.id ?? '', hasChildren: address.hasChildren))
            .toList();
      }
    } catch (e) {
      print('搜索省份失败: $e');
      // 返回模拟数据作为备选
      return [
        SelectData<String>(label: '北京市', value: 'beijing', data: 'beijing', hasChildren: true),
        SelectData<String>(label: '上海市', value: 'shanghai', data: 'shanghai', hasChildren: true),
        SelectData<String>(label: '广东省', value: 'guangdong', data: 'guangdong', hasChildren: true),
      ];
    }
  }

  // 真实API方法：懒加载省份数据
  Future<List<SelectData<String>>> _fetchProvincesLazyLoad(SelectData<dynamic> parentNode) async {
    await Future.delayed(Duration(seconds: 2));
    try {
      print('懒加载地址数据，父节点: ${parentNode.label} (${parentNode.value})');

      // 根据父节点ID获取子级数据，确保类型转换正确
      final parentId = parentNode.value?.toString();
      final response = await _addressApi.queryAddresses(parentId: parentId);

      return response.map((address) => SelectData<String>(label: address.name, value: address.id ?? '', data: address.id ?? '', hasChildren: address.hasChildren)).toList();
    } catch (e) {
      print('懒加载失败: $e');
      // 失败时返回空列表或模拟数据
      return [];
    }
  }

  // 真实API方法：获取城市列表
  Future<List<SelectData<String>>> _fetchCities(String keyword) async {
    try {
      // 获取当前选中的省份
      final selectedProvince = _controller.getValue<String?>('province');
      if (selectedProvince == null || selectedProvince.isEmpty) {
        print('未选择省份，无法获取城市');
        return [];
      }

      print('获取城市列表，省份ID: $selectedProvince，关键字: $keyword');

      // 根据省份ID获取城市数据
      final cities = await _addressApi.getCities(selectedProvince);

      // 转换为SelectData格式
      List<SelectData<String>> result = cities
          .map((city) => SelectData<String>(label: city.name, value: city.id ?? '', data: city.id ?? '', hasChildren: city.hasChildren))
          .toList();

      // 如果有关键字，进行过滤
      if (keyword.isNotEmpty) {
        result = result.where((item) => item.label.contains(keyword)).toList();
      }

      print('获取到 ${result.length} 个城市');
      return result;
    } catch (e) {
      print('获取城市失败: $e');
      return [];
    }
  }

  // 真实API方法：获取区县列表
  Future<List<SelectData<String>>> _fetchDistricts(String keyword) async {
    try {
      // 获取当前选中的城市
      final selectedCity = _controller.getValue<String?>('city_real');
      if (selectedCity == null || selectedCity.isEmpty) {
        print('未选择城市，无法获取区县');
        return [];
      }

      print('获取区县列表，城市ID: $selectedCity，关键字: $keyword');

      // 根据城市ID获取区县数据
      final districts = await _addressApi.getDistricts(selectedCity);

      // 转换为SelectData格式
      List<SelectData<String>> result = districts
          .map((district) => SelectData<String>(label: district.name, value: district.id ?? '', data: district.id ?? '', hasChildren: district.hasChildren))
          .toList();

      // 如果有关键字，进行过滤
      if (keyword.isNotEmpty) {
        result = result.where((item) => item.label.contains(keyword)).toList();
      }

      print('获取到 ${result.length} 个区县');
      return result;
    } catch (e) {
      print('获取区县失败: $e');
      return [];
    }
  }

  // 真实API方法：搜索地址
  Future<List<SelectData<String>>> _searchAddresses(String keyword) async {
    try {
      if (keyword.isEmpty) {
        print('搜索关键字为空');
        return [];
      }

      print('搜索地址，关键字: $keyword');

      // 使用搜索API
      final addresses = await _addressApi.searchAddressesByKeyword(keyword);

      // 转换为SelectData格式
      final result = addresses
          .map((address) => SelectData<String>(label: '${address.name} (${address.path})', value: address.id ?? '', data: address.id ?? '', hasChildren: address.hasChildren))
          .toList();

      print('搜索到 ${result.length} 个地址');
      return result;
    } catch (e) {
      print('搜索地址失败: $e');
      return [];
    }
  }

  // 真实API方法：搜索爱好
  Future<List<SelectData<String>>> _searchHobbies(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print('开始搜索爱好，关键字: $keyword');

      // 调用真实API
      final response = await HobbyApi.getHobbyList(
        page: 1,
        limit: 20, // 限制返回数量
        keyword: keyword.isNotEmpty ? keyword : null,
      );

      print('爱好API响应: $response');

      // 更安全的解析API响应
      final bool success = response['success'] == true;
      final dynamic data = response['data'];

      if (success && data is List) {
        // data 直接是爱好数组
        final List<SelectData<String>> result = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final dynamic hobbyJson = data[i];
            if (hobbyJson is Map<String, dynamic>) {
              final String name = hobbyJson['name'] ?? '';
              final String id = hobbyJson['id']?.toString() ?? 'hobby_$i';

              // 确保爱好数据有效
              if (name.isNotEmpty) {
                result.add(SelectData<String>(label: name, value: id, data: id));
              }
            }
          } catch (e) {
            print('解析爱好数据失败 (索引 $i): $e');
            continue; // 跳过这个爱好，继续处理下一个
          }
        }

        print('成功解析 ${result.length} 个爱好');
        return result;
      } else if (success && data is Map<String, dynamic>) {
        // data 是对象，包含 list 字段
        final dynamic listData = data['list'];

        if (listData is List) {
          final List<SelectData<String>> result = [];

          for (int i = 0; i < listData.length; i++) {
            try {
              final dynamic hobbyJson = listData[i];
              if (hobbyJson is Map<String, dynamic>) {
                final String name = hobbyJson['name'] ?? '';
                final String id = hobbyJson['id']?.toString() ?? 'hobby_$i';

                // 确保爱好数据有效
                if (name.isNotEmpty) {
                  result.add(SelectData<String>(label: name, value: id, data: id));
                }
              }
            } catch (e) {
              print('解析爱好数据失败 (索引 $i): $e');
              continue; // 跳过这个爱好，继续处理下一个
            }
          }

          print('成功解析 ${result.length} 个爱好');
          return result;
        } else {
          print('API返回的list字段不是数组类型: ${listData.runtimeType}');
          return [];
        }
      } else {
        print('API返回失败或data字段格式不正确: success=$success, data=${data.runtimeType}');
        return [];
      }
    } catch (e, stackTrace) {
      // 网络错误或其他异常，返回空列表
      print('搜索爱好失败: $e');
      print('堆栈跟踪: $stackTrace');
      return [];
    }
  }

  // 真实API方法：搜索用户
  Future<List<SelectData<User>>> _searchUsers(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print('开始搜索用户，关键字: $keyword');

      // 调用真实API
      final response = await UserApi.getUserList(
        page: 1,
        limit: 20, // 限制返回数量
        name: keyword.isNotEmpty ? keyword : null,
      );

      print('用户API响应: $response');

      // 更安全的解析API响应
      final bool success = response['success'] == true;
      final dynamic data = response['data'];

      if (success && data is List) {
        // data 直接是用户数组
        final List<SelectData<User>> result = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final dynamic userJson = data[i];
            if (userJson is Map<String, dynamic>) {
              final user = User.fromJson(userJson);

              // 确保用户数据有效
              if (user.name != null && user.name!.isNotEmpty) {
                result.add(SelectData<User>(label: '${user.name} - ${user.school ?? '未知学校'} (${user.age ?? 0}岁)', value: user.id ?? 'user_$i', data: user));
              }
            }
          } catch (e) {
            print('解析用户数据失败 (索引 $i): $e');
            continue; // 跳过这个用户，继续处理下一个
          }
        }

        print('成功解析 ${result.length} 个用户');
        return result;
      } else if (success && data is Map<String, dynamic>) {
        // data 是对象，包含 list 字段
        final dynamic listData = data['list'];

        if (listData is List) {
          final List<SelectData<User>> result = [];

          for (int i = 0; i < listData.length; i++) {
            try {
              final dynamic userJson = listData[i];
              if (userJson is Map<String, dynamic>) {
                final user = User.fromJson(userJson);

                // 确保用户数据有效
                if (user.name != null && user.name!.isNotEmpty) {
                  result.add(SelectData<User>(label: '${user.name} - ${user.school ?? '未知学校'} (${user.age ?? 0}岁)', value: user.id ?? 'user_$i', data: user));
                }
              }
            } catch (e) {
              print('解析用户数据失败 (索引 $i): $e');
              continue; // 跳过这个用户，继续处理下一个
            }
          }

          print('成功解析 ${result.length} 个用户');
          return result;
        } else {
          print('API返回的list字段不是数组类型: ${listData.runtimeType}');
          return [];
        }
      } else {
        print('API返回失败或data字段格式不正确: success=$success, data=${data.runtimeType}');
        return [];
      }
    } catch (e, stackTrace) {
      // 网络错误或其他异常，返回空列表
      print('搜索用户失败: $e');
      print('堆栈跟踪: $stackTrace');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表单标题
            const Text('ConfigForm 组件使用示例', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 表单组件
            ConfigForm(configs: _formConfigs, controller: _controller, onChanged: _onFormChanged),

            const SizedBox(height: 16),

            // 上传状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '上传状态: $_uploadStatus',
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 实时数据显示
            if (_formData.isNotEmpty) ...[
              const Text('实时表单数据:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _formData.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontFamily: 'monospace')),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Wrap(
        children: [
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('提交表单'),
          ),
          ElevatedButton(
            onPressed: _clearForm,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('清除表单'),
          ),
          ElevatedButton(
            onPressed: _setDefaultValues,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('设置默认值'),
          ),
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('重置表单'),
          ),
          ElevatedButton(
            onPressed: _viewFormData,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('查看表单数据'),
          ),
        ],
      ),
    );
  }
}
