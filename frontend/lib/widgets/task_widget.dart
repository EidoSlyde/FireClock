import 'dart:math';

import 'package:fireclock/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../task.dart';

const _taskHeight = 64.0;
const _indentWidth = 24.0;

final taskColors = [
  Colors.blue.shade400,
  Colors.orange.shade400,
  Colors.green.shade400,
];

class _TaskWidget extends StatelessWidget {
  const _TaskWidget(
    this.task, {
    required this.color,
    this.folded = false,
    this.onFolded,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanStart,
    Key? key,
  }) : super(key: key);

  final Task task;
  final bool folded;
  final void Function(bool)? onFolded;
  final void Function(DragUpdateDetails)? onPanUpdate;
  final void Function()? onPanEnd;
  final void Function()? onPanStart;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _taskHeight,
      width: double.infinity,
      color: color,
      child: Row(
        children: [
          GestureDetector(
            onPanUpdate: onPanUpdate,
            onPanEnd: (d) => onPanEnd?.call(),
            onPanStart: (d) => onPanStart?.call(),
            // It is important that the drag icon has no offset from the top and the left
            child: const SizedBox(
              height: double.infinity,
              width: 52,
              child: Icon(Icons.drag_handle),
            ),
          ),
          Text(task.name),
          const Spacer(),
          if (task.children.isNotEmpty)
            IconButton(
              onPressed: () => onFolded?.call(!folded),
              icon: AnimatedRotation(
                turns: folded ? 0.5 : 0,
                duration: const Duration(milliseconds: 140),
                child: const Icon(Icons.arrow_drop_down),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecTaskWidget extends HookConsumerWidget {
  const _RecTaskWidget(
    this.task, {
    this.foldedMap,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanStart,
    Key? key,
    this.depth = 0,
  }) : super(key: key);

  final Task task;
  final ValueNotifier<Map<int, bool>>? foldedMap;
  final void Function(DragUpdateDetails, Task)? onPanUpdate;
  final void Function()? onPanEnd;
  final void Function()? onPanStart;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folded = foldedMap?.value[task.id] ?? false;
    final childrenSizeAnim = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: folded ? 0 : 1,
      lowerBound: 0,
      upperBound: 1,
    );
    (folded ? childrenSizeAnim.reverse : childrenSizeAnim.forward)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskWidget(
          task,
          color: taskColors[depth % taskColors.length],
          folded: folded,
          onFolded: (b) {
            if (foldedMap == null) return;
            foldedMap!.value = {...foldedMap!.value, task.id: b};
          },
          onPanUpdate: (d) => onPanUpdate?.call(d, task),
          onPanEnd: onPanEnd,
          onPanStart: onPanStart,
        ),
        SizeTransition(
          sizeFactor: childrenSizeAnim,
          child: Column(children: [
            for (final e in task.children)
              Row(children: [
                const SizedBox(width: _indentWidth),
                Expanded(
                  child: _RecTaskWidget(
                    e,
                    depth: depth + 1,
                    foldedMap: foldedMap,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    onPanStart: onPanStart,
                  ),
                ),
              ])
          ]),
        )
      ],
    );
  }
}

class TaskList extends HookConsumerWidget {
  const TaskList(
    this.tasks, {
    this.onMove,
    Key? key,
  }) : super(key: key);

  final List<Task> tasks;
  final Function(Task moved, Task? parent, int childPos)? onMove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final scrollOffset = useState(0.0);
    useEffect(() {
      void l() => scrollOffset.value = scrollController.position.pixels;
      scrollController.addListener(l);
      return () => scrollController.removeListener(l);
    }, [scrollController]);
    final foldedMap = useState(
        Map<int, bool>.unmodifiable({})); // Maps task id to folded boolean
    final currentDraggingPos = useState<_CurrDraggedTask?>(null);
    final scrollOffsetAtPanStart = useState(0.0);

    bool isFolded(Task t) => foldedMap.value[t.id] ?? false;
    final flatVisTasks = tasks
        .expand((t) =>
            recToList<Task>(t, ((t2) => isFolded(t2) ? [] : t2.children)))
        .toList();

    Iterable<RecAsList<Task>> getChildren(int id) {
      final it = flatVisTasks.skipWhile((t) => t.value.id != id);
      return it.skip(1).takeWhile((t) => t.depth > it.first.depth);
    }

    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          child: Column(children: [
            for (final t in tasks)
              _RecTaskWidget(
                t,
                foldedMap: foldedMap,
                onPanUpdate: (d, task) {
                  final scrollAdjust =
                      scrollOffset.value - scrollOffsetAtPanStart.value;

                  // e.g -5 moves 5 levels up, 3 moves 3 levels down
                  final relIdxOffset =
                      ((d.localPosition.dy + scrollAdjust) / _taskHeight)
                          .floor();
                  final currVisIdx =
                      flatVisTasks.indexWhere((t) => t.value.id == task.id);
                  var newVisIdx = currVisIdx + relIdxOffset;

                  final currDepth = flatVisTasks[currVisIdx].depth;
                  final relDepthOffset =
                      (d.localPosition.dx / _indentWidth).floor();
                  var newDepth = currDepth + relDepthOffset;

                  // Ensure in bound
                  newVisIdx = newVisIdx.clamp(0, flatVisTasks.length);
                  newDepth = max(0, newDepth);

                  // First task cannot have parent
                  if (newVisIdx == 0) newDepth = 0;

                  // Can only indent one step to the right of the previous task to parent to it
                  if (newVisIdx > 0 &&
                      flatVisTasks[newVisIdx - 1].depth < newDepth - 1) {
                    newDepth = flatVisTasks[newVisIdx - 1].depth + 1;
                  }

                  // Cannot indent left if it means it would add unwanted children
                  final nextsNonChild = flatVisTasks
                      .skip(currVisIdx + 1)
                      .skipWhile((t) => t.depth > currDepth);
                  if (nextsNonChild.isNotEmpty && currVisIdx == newVisIdx) {
                    newDepth = max(newDepth, nextsNonChild.first.depth);
                  }
                  if (currVisIdx != newVisIdx &&
                      newVisIdx < flatVisTasks.length) {
                    newDepth = max(newDepth, flatVisTasks[newVisIdx].depth);
                  }

                  // Cannot put a task in its own children
                  if (relIdxOffset > 0 &&
                      getChildren(task.id).length + 1 >= relIdxOffset) {
                    newVisIdx = currVisIdx;
                    newDepth = currDepth;
                  }

                  currentDraggingPos.value = _CurrDraggedTask(
                      newVisIdx: newVisIdx, newDepth: newDepth, task: task);
                },
                onPanEnd: () {
                  if (currentDraggingPos.value == null) return;
                  final moved = currentDraggingPos.value!.task;

                  var parentVisIdx = currentDraggingPos.value!.newVisIdx - 1;
                  var childPos = 0;
                  while (parentVisIdx >= 0 &&
                      flatVisTasks[parentVisIdx].depth >=
                          currentDraggingPos.value!.newDepth) {
                    if (flatVisTasks[parentVisIdx].depth ==
                        currentDraggingPos.value!.newDepth) {
                      childPos += 1;
                    }
                    parentVisIdx -= 1;
                  }
                  final parent = parentVisIdx < 0
                      ? null
                      : flatVisTasks[parentVisIdx].value;

                  onMove?.call(moved, parent, childPos);
                  currentDraggingPos.value = null;
                },
                onPanStart: () =>
                    scrollOffsetAtPanStart.value = scrollOffset.value,
              ),
            const SizedBox(height: 12),
          ]),
        ),
        if (currentDraggingPos.value != null)
          Padding(
            padding: EdgeInsets.only(
              top: max(
                  0,
                  currentDraggingPos.value!.newVisIdx * _taskHeight -
                      scrollOffset.value),
              left: max(0, currentDraggingPos.value!.newDepth * _indentWidth),
            ),
            child: Container(
              width: double.infinity,
              height: 8,
              color: Colors.black,
            ),
          )
      ],
    );
  }
}

class _CurrDraggedTask {
  final int newVisIdx;
  final int newDepth;
  final Task task;

  _CurrDraggedTask({
    required this.newVisIdx,
    required this.newDepth,
    required this.task,
  });
}
