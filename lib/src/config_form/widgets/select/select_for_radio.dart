import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/utils/basic_style.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class SelectForRadio extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final void Function(Map<String, dynamic>)? onChanged;
  const SelectForRadio({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<SelectForRadio> createState() => _SelectForRadioState();
}

class _SelectForRadioState extends State<SelectForRadio> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final errorsInfo = widget.controller.errors;
    final String groupValue = widget.controller.getValue<String?>(config.name) ?? '';
    final props = config.props; // dynamic
    final options = (props?.options as List?) ?? []; // List<dynamic>

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelInfo(config.label, config.required),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 18),
              child: InputDecorator(
                decoration: BasicStyle.inputStyle(config.label),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: options.map<Widget>((opt) {
                    final String valueStr = opt.value.toString();

                    void handleChange() {
                      widget.controller.setFieldValue(config.name, valueStr);
                      if (props != null && props.onChanged != null) {
                        props.onChanged(opt.value, opt.data, opt);
                      }
                    }

                    return InkWell(
                      onTap: handleChange,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(opt.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                          Radio<String>(
                            value: valueStr,
                            groupValue: groupValue,
                            onChanged: (val) {
                              if (val != null) {
                                handleChange();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (errorsInfo[config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[config.name]!)),
          ],
        ),
      ],
    );
  }
}
