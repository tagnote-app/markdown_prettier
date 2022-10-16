import 'package:source_span/source_span.dart';

import '../builder.dart';
import '../extensions.dart';
import '../models/pretty_node.dart';

class BlockquoteBuilder extends MarkdownBuilder {
  BlockquoteBuilder();

  @override
  final matchTypes = ['blockquote'];

  @override
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {
    if (!element.isLastChild) {
      element.writeln();
    }
  }

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    final children = element.children;
    if (children.isEmpty) {
      return [];
    }

    _patchMarkers(markers, element);
    _cleanupMarkers(markers, element);
    for (final marker in markers) {
      if (_hasNoContent(marker, element)) {
        marker.writeln();
      } else {
        marker.appendSpace();
      }
    }

    _addExtraLines(markers, element);

    return markers;
  }

  /// Adds missing makers.
  // For example:
  // ```
  // > foo
  // bar
  // > baz
  // ```
  void _patchMarkers(List<PrettyMarker> markers, PrettyElement element) {
    for (var line = element.start.line; line < element.end.line + 1; line++) {
      if (markers.every((e) => e.end.line != line)) {
        final markerLocation =
            element.startLocations().firstWhereOrNull((e) => e.line == line);
        if (markerLocation == null) {
          continue;
        }
        markers.add(
          PrettyMarker.zeroWidth('>', markerLocation),
        );
      }
    }
  }

  // For example:
  // ```
  // > # Foo
  // > bar
  // > baz
  // ```
  void _addExtraLines(List<PrettyMarker> markers, PrettyElement element) {
    SourceLocation? patchAt;
    for (final child in element.children) {
      if (child is! PrettyElement) {
        continue;
      }
      if (child.type == 'atxHeading') {
        patchAt = child.end;
      } else if (patchAt != null) {
        markers.add(PrettyMarker.zeroWidth('\n>', patchAt));
        patchAt = null;
      }
    }
  }

  // Remove the leading and trailing markers which do not have following
  // content.
  void _cleanupMarkers(List<PrettyMarker> markers, PrettyElement element) {
    final from = element.children.first.start.offset;
    final end = element.children.last.end.offset;

    markers.removeWhere((marker) =>
        (marker.end.offset < from && _hasNoContent(marker, element)) ||
        marker.start.offset > end);
  }

  /// Whether a line has nothing other than markers.
  bool _hasNoContent(PrettyMarker marker, PrettyElement element) {
    return element
        .getDescendants(true)
        .every((node) => node.start.line != marker.end.line);
  }
}
