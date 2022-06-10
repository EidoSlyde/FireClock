import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../task.dart';

class TopInfo extends HookConsumerWidget {
  const TopInfo({
    required this.activityTimeUnit,
    required this.quotaTimeUnit,
    required this.onQuotaChange,
    required this.onTextChange,
    this.initialText,
    this.initalQuota = 1,
    this.onActivityTimeUnitChange,
    this.onQuotaTimeUnitChange,
    Key? key,
  }) : super(key: key);

  final String? initialText;
  final double initalQuota;
  final Function(double) onQuotaChange;
  final Function(String) onTextChange;
  final ActivityTimeUnit activityTimeUnit;
  final QuotaTimeUnit quotaTimeUnit;
  final Function(ActivityTimeUnit)? onActivityTimeUnitChange;
  final Function(QuotaTimeUnit)? onQuotaTimeUnitChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotaController = useTextEditingController(
      text: initalQuota.toInt().toString(),
    );

    useEffect(() {
      void l() {
        final d = double.tryParse(quotaController.text);
        if (d != null) {
          onQuotaChange(d);
        }
      }

      quotaController.addListener(l);
      return () => quotaController.removeListener(l);
    }, [quotaController]);

    final textController = useTextEditingController(
      text: initialText,
    );
    useEffect(() {
      void l() => onTextChange(textController.text);
      textController.addListener(l);
      return () => textController.removeListener(l);
    }, [textController]);

    const dropdownPadding = EdgeInsets.only(left: 10);

    return SizedBox(
      height: 86,
      child: Row(children: [
        Flexible(
          child: TextField(
            controller: textController,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        SizedBox(
          width: 48,
          child: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: const InputDecoration(border: InputBorder.none),
            textAlign: TextAlign.end,
            controller: quotaController,
          ),
        ),
        const SizedBox(width: 20),
        DropdownButton<ActivityTimeUnit>(
          value: activityTimeUnit,
          items: const [
            DropdownMenuItem(
              value: ActivityTimeUnit.minute,
              child: Padding(padding: dropdownPadding, child: Text("Minutes")),
            ),
            DropdownMenuItem(
              value: ActivityTimeUnit.hour,
              child: Padding(padding: dropdownPadding, child: Text("Hour")),
            ),
            DropdownMenuItem(
              value: ActivityTimeUnit.day,
              child: Padding(padding: dropdownPadding, child: Text("Day")),
            ),
          ],
          onChanged: (d) {
            if (d == null) return;
            onActivityTimeUnitChange?.call(d);
          },
        ),
        const SizedBox(width: 20),
        const Text("per"),
        const SizedBox(width: 20),
        DropdownButton<QuotaTimeUnit>(
          value: quotaTimeUnit,
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
            onQuotaTimeUnitChange?.call(d);
          },
        ),
      ]),
    );
  }
}
