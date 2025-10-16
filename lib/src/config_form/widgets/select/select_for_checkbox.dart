import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/utils/basic_style.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class SelectForCheckbox extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const SelectForCheckbox({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForCheckbox> createState() => _SelectForCheckboxState();
}

class _SelectForCheckboxState extends State<SelectForCheckbox> {
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
            LabelInfo(config.label, config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: InputDecorator(
                    decoration: BasicStyle.inputStyle(config.label),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (config.props as CheckboxProps?)?.options.map<Widget>((opt) {
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              value: false,
                              title: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              onChanged: (bool? v) {
                                if (v == null) return;
                                config.props.onChanged?.call(v);
                              },
                            );
                          }).toList() ??
                          <Widget>[],
                    ),
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
