import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/utils/basic_style.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class InputForNumber extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const InputForNumber({super.key, required this.config, required this.controller, required this.onChanged});

  @override
  State<InputForNumber> createState() => _InputForNumberState();
}

class _InputForNumberState extends State<InputForNumber> {
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
                    initialValue: widget.controller.getValue<dynamic>(config.name)?.toString() ?? '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: BasicStyle.inputStyle(config.label),
                    onChanged: (val) {
                      widget.controller.setFieldValue(config.name, val);
                      widget.onChanged?.call(widget.controller.getFormData());
                      config.props.onChanged?.call(double.tryParse(val) ?? 0);
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
