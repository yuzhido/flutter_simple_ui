import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/src/config_form/config_form_controller.dart';

/// 第一个参数将会在运行时传入 FormConfig（或兼容对象），以便在回调中可获取验证器等能力
typedef ContentBuilder = Widget Function(dynamic config, ConfigFormController controller, Function(String) onChanged);
