import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/form_config.dart';
import 'package:flutter_simple_ui/src/config_form/config_form_controller.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';
import 'package:flutter_simple_ui/src/tree_select/index.dart';

class SelectForTree<T> extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final void Function(Map<String, dynamic>)? onChanged;
  const SelectForTree({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForTree> createState() => _SelectForTreeState<T>();
}

class _SelectForTreeState<T> extends State<SelectForTree> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: TreeSelect<dynamic>(
                    key: ValueKey('treeSelect_${widget.config.name}_'), // 使用key强制重新创建组件
                    defaultValue: [],
                    options: (config.props)?.options ?? [],
                    multiple: (config.props)?.multiple ?? false,
                    title: (config.props)?.title ?? '树形选择器',
                    hintText: (config.props)?.hintText ?? '请输入关键字搜索',
                    remoteFetch: (config.props)?.remoteFetch,
                    remote: (config.props)?.remote ?? false,
                    filterable: (config.props)?.filterable ?? false,
                    lazyLoad: (config.props)?.lazyLoad ?? false,
                    lazyLoadFetch: (config.props)?.lazyLoadFetch,
                    isCacheData: (config.props)?.isCacheData ?? true,
                    onSingleChanged: (value, data, selectedData) {
                      final valueStr = value?.toString() ?? '';
                      widget.controller.setFieldValue(widget.config.name, valueStr);
                      (config.props)?.onSingleChanged?.call(value, data, selectedData);
                    },
                    onMultipleChanged: (values, datas, selectedDataList) {
                      final valueStr = values.map((v) => v?.toString() ?? '').where((s) => s.isNotEmpty).join(',');
                      widget.controller.setFieldValue(widget.config.name, valueStr);
                      (config.props)?.onMultipleChanged?.call(values, datas, selectedDataList);
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
