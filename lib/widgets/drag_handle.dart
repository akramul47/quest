import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DragHandle extends StatefulWidget {
  const DragHandle({super.key});

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isDragging = true);
        windowManager.startDragging();
      },
      onPanEnd: (details) {
        setState(() => _isDragging = false);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: _isDragging
                ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
