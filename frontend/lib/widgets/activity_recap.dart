import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ActivityRecap extends HookConsumerWidget {
  const ActivityRecap({
    required this.date,
    required this.quota,
    required this.totalActivity,
    Key? key,
  }) : super(key: key);

  final DateTime date;
  final double quota;
  final double totalActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    const top = "05h";
    const bottom = "10m";

    const circleWidget = Center(
      child: Text(
        '$top\n$bottom',
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      width: 220,
      height: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(dateFormat.format(date)),
          const SizedBox(height: 42),
          circleWidget,
        ],
      ),
    );
  }
}
