import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class CustomForAny extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const CustomForAny({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<CustomForAny> createState() => _CustomForAnyState();
}

class _CustomForAnyState extends State<CustomForAny> {
  late ValueNotifier<Map<String, String>> countNotifier;
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FormConfig customCfg = widget.config;
    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, _, __) {
        final child = customCfg.props.contentBuilder(customCfg, widget.controller, (val) {
          // 避免在build期间调用 setState，延后
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.controller.setFieldValue(customCfg.name, val);
          });
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.config.label != '') LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(padding: EdgeInsets.only(bottom: 18), child: child),
                if (errorsInfo[config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[config.name]!)),
              ],
            ),
          ],
        );
      },
    );
  }
}
