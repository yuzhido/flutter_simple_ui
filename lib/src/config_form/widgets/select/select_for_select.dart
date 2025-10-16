import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/form_config.dart';
import 'package:flutter_simple_ui/src/config_form/config_form_controller.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class SelectForSelect extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;
  const SelectForSelect({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForSelect> createState() => _SelectForSelectState();
}

class _SelectForSelectState extends State<SelectForSelect> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [LabelInfo('下来选', true), const Text('组件内容')]);
  }
}
