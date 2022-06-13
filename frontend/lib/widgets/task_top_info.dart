import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../task.dart';

class TaskTopInfo extends HookConsumerWidget {
  const TaskTopInfo({
    Key? key,
    required this.task,
    required this.onNameChange,
    required this.onQuotaChange,
    required this.onQuotaTimeUnitChange,
  }) : super(key: key);

  final Task task;
  final Function(QuotaTimeUnit) onQuotaTimeUnitChange;
  final Function(String) onNameChange;
  final Function(int minutes) onQuotaChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(text: task.name);
    BehaviorSubject<String> textChange;

    useEffect(() {
      textChange = BehaviorSubject();
      textChange
          .debounceTime(const Duration(milliseconds: 256))
          .listen((value) => onNameChange(value));
      textController.addListener(() => textChange.add(textController.text));
      return () => textChange.close();
    }, [textController]);

    final minutes = useState<int>(task.quota % 60);
    final hours = useState<int>((task.quota ~/ 60) % 24);
    final days = useState<int>((task.quota ~/ 60) ~/ 24);

    useEffect(() {
      final x = days.value * 24 * 60 + hours.value * 60 + minutes.value;
      if (x == task.quota) return;
      onQuotaChange(x);
      return null;
    }, [days.value, hours.value, minutes.value]);

    const dropdownPadding = EdgeInsets.only(left: 10);

    return SizedBox(
      height: 80,
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: textController,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("days"),
            CustomNumberPicker<num>(
              onValue: (v) => days.value = v.toInt(),
              initialValue: days.value,
              minValue: 0,
              maxValue: 9999,
              step: 1,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("hours"),
            CustomNumberPicker<num>(
              onValue: (v) => hours.value = v.toInt(),
              initialValue: hours.value,
              minValue: 0,
              maxValue: 23,
              step: 1,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("minutes"),
            CustomNumberPicker<num>(
              onValue: (v) => minutes.value = v.toInt(),
              initialValue: minutes.value,
              minValue: 0,
              maxValue: 59,
              step: 5,
            ),
          ],
        ),
        const Text("        per        "),
        DropdownButton<QuotaTimeUnit>(
          value: task.quotaTimeUnit,
          items: const [
            DropdownMenuItem(
              value: QuotaTimeUnit.day,
              child: Padding(padding: dropdownPadding, child: Text("Day")),
            ),
            DropdownMenuItem(
              value: QuotaTimeUnit.week,
              child: Padding(padding: dropdownPadding, child: Text("Week")),
            ),
            DropdownMenuItem(
              value: QuotaTimeUnit.month,
              child: Padding(padding: dropdownPadding, child: Text("Month")),
            ),
          ],
          onChanged: (d) {
            if (d == null) return;
            onQuotaTimeUnitChange(d);
          },
        ),
      ]),
    );
  }
}
