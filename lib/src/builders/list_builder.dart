import 'package:source_span/source_span.dart';

import '../builder.dart';
import '../models/pretty_node.dart';

class ListBuilder extends MarkdownBuilder {
  final _listStrack = <_ListElement>[];

  @override
  final matchTypes = ['orderedList', 'bulletList', 'listItem'];

  @override
  void visitElementBefore(PrettyElement element, PrettyElement? parent) {
    if (_isList(element.type)) {
      _listStrack.add(_ListElement(element, _listStrack.length));
    } else {
      final currentList = _listStrack.last;
      final level = currentList.level;
      final listItemMarker = _listItemMarker(
        currentList.isOrdered,
        element,
        element.markers,
      );

      currentList.leadingSpaces = listItemMarker.length + 1;
      if (level > 0) {
        currentList.leadingSpaces += _listStrack[level - 1].leadingSpaces;
      }
    }
  }

  @override
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {
    if (_isList(element.type)) {
      final currentList = _listStrack.removeLast();
      if (currentList.level > 0 && !_listStrack.last.isTight) {
        element.writeln();
      }
    }
    if (_listStrack.isEmpty && !element.isLastChild) {
      element.writeln();
    }
  }

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    if (_isList(element.type)) {
      return [];
    }

    final currentList = _listStrack.last;
    final isOrdered = currentList.isOrdered;
    final level = currentList.level;

    var leadingSpaces = 0;
    if (level > 0) {
      final parentList = _listStrack[level - 1];
      leadingSpaces = parentList.leadingSpaces;
    }

    markers[0]
      ..appendSpace()
      ..prependSpaces(leadingSpaces)
      ..updateText(_listItemMarker(isOrdered, element, markers));

    return markers;
  }

  /*
  @override
  List<PrettyNode> prettyChildren(children, element, parent) {
    if (parent != null) {
      if (_isList(parent.type) && parent.attributes['isTight'] == 'false') {
        children.last.writeln();
      }
    }
    return children;
  }
  */
}

class _ListElement {
  _ListElement(PrettyElement element, this.level) : _element = element;

  final PrettyElement _element;
  final int level;

  /// The leading space for the child list of current list item.
  /// This value is dynamic.
  int leadingSpaces = 0;

  String get type => _element.type;
  bool get isOrdered => _element.type == 'orderedList';
  bool get isTight => _element.attributes['isTight'] == 'true';
}

/// Returns a marker for currrent list item.
String _listItemMarker(
  bool isOrdered,
  PrettyElement element,
  List<SourceSpan> markers,
) =>
    isOrdered ? '${element.attributes['number']}.' : markers.first.text;

/// If it is a list Element.
bool _isList(String type) => type == 'orderedList' || type == 'bulletList';
