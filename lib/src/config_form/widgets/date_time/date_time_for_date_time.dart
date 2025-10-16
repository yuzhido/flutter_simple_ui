import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/utils/basic_style.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';

class DateTimeForDateTime extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final Function(Map<String, dynamic>)? onChanged;

  const DateTimeForDateTime({super.key, required this.config, required this.controller, required this.onChanged});
  @override
  State<DateTimeForDateTime> createState() => _DateTimeForDateTimeState();
}

class _DateTimeForDateTimeState extends State<DateTimeForDateTime> {
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
                    decoration: BasicStyle.inputStyle(widget.config.label, suffixIcon: const Icon(Icons.event)),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (pickedDate == null) return;
                      if (!context.mounted) return;
                      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (pickedTime == null) return;
                      two(int v) => v.toString().padLeft(2, '0');
                      final dateStr = '${pickedDate.year}-${two(pickedDate.month)}-${two(pickedDate.day)}';
                      final timeStr = '${two(pickedTime.hour)}:${two(pickedTime.minute)}';
                      final dateTimeStr = '$dateStr $timeStr';
                      controller.text = dateTimeStr;
                      widget.controller.setFieldValue(widget.config.name, dateTimeStr);
                      widget.onChanged?.call(widget.controller.getFormData());
                      widget.config.props?.onChanged?.call(dateTimeStr);
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
