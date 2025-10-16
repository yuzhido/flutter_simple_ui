import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';
import 'package:flutter_simple_ui/src/dropdown_choose/index.dart';

class SelectForDropdown<T> extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const SelectForDropdown({super.key, required this.config, required this.controller, required this.onChanged});

  @override
  State<SelectForDropdown<T>> createState() => _DropdownFieldContentState<T>();
}

class _DropdownFieldContentState<T> extends State<SelectForDropdown<T>> {
  dynamic defaultValue;
  @override
  void initState() {
    super.initState();
    defaultValue = widget.config.defaultValue;
    countNotifier = ValueNotifier(widget.controller.errors);
  }

  late ValueNotifier<Map<String, String>> countNotifier;

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        // final dynamic currentValue = widget.controller.getValue<dynamic>(config.name) ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(config.label, config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: DropdownChoose<dynamic>(
                    key: ValueKey('dropdown_${config.name}'), // 使用稳定的key，避免因值变化导致组件重建
                    options: config.props?.options,
                    multiple: config.props?.multiple,
                    filterable: config.props?.filterable,
                    remote: config.props?.remote,
                    remoteSearch: config.props?.remoteSearch,
                    showAdd: config.props?.showAdd,
                    onAdd: config.props?.onAdd,
                    alwaysRefresh: config.props?.alwaysRefresh,
                    tips: (config.props?.tips == '') ? '请选择${config.label}' : config.props?.tips,
                    defaultValue: defaultValue,
                    onSingleChanged: (value, data, selected) {
                      defaultValue = selected;
                      widget.controller.setFieldValue(config.name, value);
                      config.props?.onSingleChanged?.call(value, data, selected);
                    },
                    onMultipleChanged: (values, datas, selectedList) {
                      defaultValue = selectedList;
                      widget.controller.setFieldValue(config.name, values);
                      config.props?.onMultipleChanged?.call(values, datas, selectedList);
                    },
                  ),
                ),
                if (errorsInfo[config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[config.name]!)),
              ],
            ),
          ],
        );
      },
    );
  }
}
