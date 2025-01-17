import 'package:flutter/material.dart';

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

  /// MATEUSZ LAUDAN'S COMMENTS:
  ///
  /// pitfall: in this scenario (for such dock items) the size below (height, width) works correctly
  /// this is not dynamic
  final double height = 75;
  final double width = 330;

  /// for purposes, [SliverReorderableList] has been used - it enables reorder of the list's items
  /// pitfall: the items are draggable horizontally only - as [scrollDirection] in parent widget [CustomScrollView] assigned

  /// animation [Transform.scale] was used in reordering the elements

  /// TODO: use [Draggable] and [DragTarget] for drag and drop functionalities
  /// better for custom dragging interactions

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      height: height,
      width: width,
      padding: const EdgeInsets.all(4),
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverReorderableList(
            autoScrollerVelocityScalar:
                100, // changed for user's experience only
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ReorderableDragStartListener(
                  key: ValueKey(index),
                  index: index,
                  child: widget.builder(_items[index]));
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.2 * animation.value,
                    child: child,
                  );
                },
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }
}
