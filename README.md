# flutter_simple_ui

自定义简单 UI 组件库，适用于 Flutter，提供常用的下拉选择、级联选择、树形选择、文件上传、消息通知等高复用性组件，助力中后台/表单/管理端等场景快速开发。

## 特性

- 🌟 [下拉选择](lib/src/dropdown_choose/README.md)（支持本地/远程、单选/多选、可搜索）
- 🌳 [树形选择](lib/src/tree_select/README.md)（支持本地/远程、懒加载、多选模式）
- 📤 [文件上传](lib/src/file_upload/README.md)（支持图片、文件、拍照、可自定义触发器）
- 🔔 [消息通知](lib/src/notice_info/README.md)（支持滚动、点击、样式自定义）
- 📱 [二维码扫描](lib/src/scan_qrcode/README.md)（支持相机扫描、相册选择、闪光灯控制）
- 📊 [表格展示](lib/src/table_show/README.md)（支持固定列、自定义样式、动态行高）
- ⏳ [加载数据](lib/src/loading_data/README.md)（支持自定义加载状态和样式）
- 📋 [配置表单](lib/src/config_form/README.md)（动态表单生成，支持多种输入类型）

## 安装

在 `pubspec.yaml` 添加依赖：

```yaml
flutter_simple_ui: ^latest
```

或使用命令：

```shell
flutter pub add flutter_simple_ui
```

## 快速上手

```dart
import 'package:flutter_simple_ui/flutter_simple_ui.dart';
```

## 依赖

- file_picker
- image_picker
- flutter_svg
- mobile_scanner

## 贡献

欢迎提 issue 或 PR 参与贡献！

## 开源协议

MIT License

更多用法和高级示例请见 [example/](example/) 目录和源码注释。
