import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/utils/basic_style.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class InputForText extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const InputForText({super.key, required this.config, required this.controller, required this.onChanged});

  @override
  State<InputForText> createState() => _InputForTextState();
}

class _InputForTextState extends State<InputForText> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  FocusNode focusNode = FocusNode();
  //页面销毁
  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final errorsInfo = widget.controller.errors;

    // 优先使用配置中指定的键盘类型和输入格式化器
    TextInputType keyboardType = config.props.keyboardType ?? TextInputType.text;
    List<TextInputFormatter>? inputFormatters = config.props.inputFormatters;

    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelInfo(config.label, config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: TextFormField(
                    focusNode: focusNode,
                    onTapOutside: (e) => {focusNode.unfocus()},
                    initialValue: widget.controller.getValue<String?>(config.name) ?? '',
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: BasicStyle.inputStyle(config.label),
                    onChanged: (val) {
                      widget.controller.setFieldValue(config.name, val);
                      widget.onChanged?.call(widget.controller.getFormData());
                      config.props.onChanged?.call(val);
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
