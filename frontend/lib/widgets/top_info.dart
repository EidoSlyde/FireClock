import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../task.dart';

class TopInfo extends HookConsumerWidget {
  const TopInfo({
    required this.text,
    required this.activityTimeUnit,
    required this.quotaTimeUnit,
    required this.onQuotaChange,
    this.initalQuota = 1,
    this.onActivityTimeUnitChange,
    this.onQuotaTimeUnitChange,
    Key? key,
  }) : super(key: key);

  final String text;
  final double initalQuota;
  final Function(double) onQuotaChange;
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
      void l() => onQuotaChange(double.parse(quotaController.text));
      quotaController.addListener(l);
      return () => quotaController.removeListener(l);
    }, [quotaController]);

    const dropdownPadding = EdgeInsets.only(left: 10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      height: 86,
      child: Row(children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32),
        ),
        const Spacer(),
        SizedBox(
          width: 90,
          child: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
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
