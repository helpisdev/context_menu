import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'context_menu.dart';

/// Show a [ContextMenu] on the given [BuildContext]. For other parameters, see
/// [ContextMenu].
void showContextMenu({
  required final Offset offset,
  required final BuildContext context,
  required final List<Widget> children,
  required final double verticalPadding,
  required final double width,
  final Color? background,
}) {
  unawaited(
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        barrierColor: Colors.transparent,
      ),
      builder: (final BuildContext context) => ContextMenu(
        position: offset,
        verticalPadding: verticalPadding,
        width: width,
        background: background,
        children: children,
      ),
    ),
  );
}

/// The [ContextMenuArea] is the way to use a [ContextMenu]
///
/// It listens for right click and long press and executes [showContextMenu]
/// with the corresponding location [Offset].
class ContextMenuArea extends StatelessWidget {
  const ContextMenuArea({
    required this.child,
    required this.items,
    this.verticalPadding = 8,
    this.width = 320,
    this.background,
    super.key,
  });

  final Color? background;

  /// The widget displayed inside the [ContextMenuArea]
  final Widget child;

  /// A [List] of items to be displayed in an opened [ContextMenu]
  ///
  /// Usually, a [ListTile] might be the way to go.
  final List<Widget> items;

  /// The padding value at the top an bottom between the edge of the
  /// [ContextMenu] and the first / last item
  final double verticalPadding;

  /// The width for the [ContextMenu]. 320 by default according to Material
  /// Design specs.
  final double width;

  @override
  Widget build(final BuildContext context) => Semantics(
        label: MaterialLocalizations.of(context).popupMenuLabel,
        child: GestureDetector(
          onSecondaryTapDown: (final TapDownDetails details) =>
              _showContextMenu(details.globalPosition, context),
          onLongPressStart: (final LongPressStartDetails details) =>
              _showContextMenu(details.globalPosition, context),
          child: child,
        ),
      );

  void _showContextMenu(final Offset position, final BuildContext context) =>
      showContextMenu(
        offset: position,
        context: context,
        children: items,
        verticalPadding: verticalPadding,
        width: width,
        background: background,
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('background', background))
      ..add(DoubleProperty('verticalPadding', verticalPadding))
      ..add(DoubleProperty('width', width));
  }
}
