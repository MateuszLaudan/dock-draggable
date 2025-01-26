import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  late int? hoveredIndex;
  late double baseItemHeight;
  late double baseTranslationY;
  late double verticlItemsPadding;

  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    baseItemHeight = 64;
    verticlItemsPadding = 5;
    baseTranslationY = 0.0;
  }

  double getTranslationY(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -9,
      nonHoveredMaxValue: -5,
    );
  }

  double getPropertyValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    late final double propertyValue;

    // 1.
    if (hoveredIndex == null) {
      return baseValue;
    }

    // 2.
    final difference = (hoveredIndex! - index).abs();

    // 3.
    final itemsAffected = _items.length;

    // 4.
    if (difference == 0) {
      propertyValue = maxValue;

      // 5.
    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;

      propertyValue = lerpDouble(baseValue, nonHoveredMaxValue, ratio)!;

      // 6.
    } else {
      propertyValue = baseValue;
    }

    return propertyValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(4),
        child: ReorderableWrap(
          runAlignment: WrapAlignment.center,
          scrollDirection: Axis.horizontal,
          needsLongPressDraggable: false,
          children: _items
              .map((e) => Tooltip(
                    preferBelow: false,
                    verticalOffset: 50,
                    exitDuration: Duration.zero,
                    showDuration: Duration.zero,
                    message: e.toString(),
                    child: MouseRegion(
                      key: ValueKey(e),
                      onEnter: ((event) {
                        setState(() {
                          hoveredIndex = _items.indexOf(e);
                        });
                      }),
                      onExit: (event) {
                        setState(() {
                          hoveredIndex = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        transform: Matrix4.identity()
                          ..translate(
                            0.0,
                            getTranslationY(_items.indexOf(e)),
                            0.0,
                          ),
                        child: widget.builder(e),
                      ),
                    ),
                  ))
              .toList(),
          buildDraggableFeedback: (context, direction, children) {
            return children;
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = _items.removeAt(oldIndex);

              _items.insert(newIndex, item);
            });
          },
        ));
  }
}
