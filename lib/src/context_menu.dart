import 'dart:async';
import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'context_menu_area.dart';

/// The actual [ContextMenu] to be displayed.
///
/// You will most likely use [showContextMenu] to manually display a
/// [ContextMenu].
///
/// If you just want to use a normal [ContextMenu], please use
/// [ContextMenuArea].
class ContextMenu extends StatefulWidget {
  const ContextMenu({
    required this.position,
    required this.children,
    this.verticalPadding = 8,
    this.width = 320,
    this.background,
    super.key,
  });

  final Color? background;

  /// The [Offset] from coordinate origin the [ContextMenu] will be displayed
  /// at.
  final Offset position;

  /// The items to be displayed. [ListTile] is very useful in most cases.
  final List<Widget> children;

  /// The padding value at the top an bottom between the edge of the
  /// [ContextMenu] and the first / last item.
  final double verticalPadding;

  /// The width for the [ContextMenu]. 320 by default according to Material
  /// Design specs.
  final double width;

  @override
  State<ContextMenu> createState() => _ContextMenuState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Offset>('position', position))
      ..add(DoubleProperty('verticalPadding', verticalPadding))
      ..add(DoubleProperty('width', width))
      ..add(ColorProperty('background', background))
      ..add(IterableProperty<Widget>('children', children));
  }
}

class _ContextMenuState extends State<ContextMenu>
    with AfterLayoutMixin<ContextMenu> {
  late final List<Widget> _children;
  final List<_ContextMenuItemKey> _keys = <_ContextMenuItemKey>[];
  final Map<_ContextMenuItemKey, double> _heights =
      <_ContextMenuItemKey, double>{};

  @override
  FutureOr<void> afterFirstLayout(final BuildContext context) {
    for (final _ContextMenuItemKey key in _keys) {
      setState(() {
        _heights[key] = key.currentContext!.size!.height;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _children = widget.children.map(
      (final Widget e) {
        const _ContextMenuItemKey key = _ContextMenuItemKey();
        _keys.add(key);
        return KeyedSubtree(key: key, child: e);
      },
    ).toList();
  }

  @override
  Widget build(final BuildContext context) => AnimatedPadding(
        padding: calcPadding(context),
        duration: kShortDuration,
        child: SizedBox.shrink(
          child: Card(
            color: widget.background,
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: kBorderRadius),
            child: ClipRRect(
              borderRadius: kBorderRadius,
              child: Material(
                color: Colors.transparent,
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                    vertical: widget.verticalPadding,
                  ),
                  children: _children,
                ),
              ),
            ),
          ),
        ),
      );

  EdgeInsets calcPadding(final BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double init = _verticalPadding + _currentVisibleSpace;
    final double height = min(_heights.values.fold(init, _add), size.height);

    double paddingLeft = widget.position.dx;
    double paddingTop = widget.position.dy;
    double paddingRight = size.width - widget.position.dx - widget.width;
    if (paddingRight < 0) {
      paddingLeft += paddingRight;
      paddingRight = 0;
    }
    double paddingBottom = size.height - widget.position.dy - height;
    if (paddingBottom < 0) {
      paddingTop += paddingBottom;
      paddingBottom = 0;
    }
    return EdgeInsets.fromLTRB(
      paddingLeft,
      paddingTop,
      paddingRight,
      paddingBottom,
    );
  }

  double get _currentVisibleSpace =>
      (widget.children.length - _heights.length) * kMinTileHeight;

  double get _verticalPadding => 2 * widget.verticalPadding;

  double _add(final double val1, final double val2) => val1 + val2;

  static const double kMinTileHeight = 24;

  static const Duration kShortDuration = Duration(milliseconds: 75);

  static const BorderRadius kBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );
}

class _ContextMenuItemKey extends GlobalKey {
  const _ContextMenuItemKey() : super.constructor();
}
