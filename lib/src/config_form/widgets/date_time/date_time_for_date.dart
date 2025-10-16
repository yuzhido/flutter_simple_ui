import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/utils/basic_style.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class DateTimeForDate extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const DateTimeForDate({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<DateTimeForDate> createState() => _DateTimeForDateState();
}

class _DateTimeForDateState extends State<DateTimeForDate> {
  late ValueNotifier<Map<String, String>> countNotifier;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    countNotifier = ValueNotifier(widget.controller.errors);
    controller.text = widget.config.defaultValue ?? widget.controller.getValue(widget.config.name) ?? '';
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
            LabelInfo(widget.config.label, widget.config.required),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  child: TextFormField(
                    focusNode: focusNode,
                    onTapOutside: (e) => {focusNode.unfocus()},
                    readOnly: true,
                    controller: controller,
                    decoration: BasicStyle.inputStyle(widget.config.label, suffixIcon: const Icon(Icons.calendar_today)),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) {
                        final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        controller.text = dateStr;
                        widget.controller.setFieldValue(widget.config.name, dateStr);
                        widget.onChanged?.call(widget.controller.getFormData());
                        widget.config.props?.onChanged?.call(dateStr);
                      }
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
