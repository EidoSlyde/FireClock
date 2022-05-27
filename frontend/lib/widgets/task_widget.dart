import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _taskHeight = 64.0;
const _vertPaddingSize = 6.0;
const _leftPaddingSize = 24.0;

final taskColors = [
  Colors.blue.shade400,
  Colors.orange.shade400,
  Colors.green.shade400,
];

class TaskItem extends HookConsumerWidget {
  const TaskItem({
    Key? key,
    this.name = "",
    this.selected = false,
    this.onSelect,
    required this.color,
    this.children = const [],
  }) : super(key: key);

  final String name;
  final Color color;
  final bool selected;
  final Function()? onSelect;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAnimationController = useAnimationController(
        duration: const Duration(milliseconds: 150),
        initialValue: 1,
        lowerBound: 0,
        upperBound: 1);

    final opened = useState(false);

    (opened.value
        ? childrenAnimationController.forward
        : childrenAnimationController.reverse)();

    final singleTask = GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          border: selected ? Border.all(color: Colors.black, width: 3) : null,
          borderRadius: BorderRadius.circular(4),
          color: color,
        ),
        height: _taskHeight - _vertPaddingSize,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            AnimatedRotation(
              turns: opened.value ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                iconSize: 16,
                onPressed: () => opened.value = !opened.value,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                  fontSize: 18, fontWeight: selected ? FontWeight.bold : null),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: _vertPaddingSize / 2),
            child: singleTask),
        SizeTransition(
          sizeFactor: CurvedAnimation(
              parent: childrenAnimationController, curve: Curves.easeOut),
          child: Column(children: [
            for (final child in children)
              Padding(
                padding: const EdgeInsets.only(left: _leftPaddingSize),
                child: child,
              )
          ]),
        ),
      ],
    );
  }
}
