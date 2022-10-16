import 'dart:convert';
import 'package:source_span/source_span.dart';

import 'models/pretty_node.dart';

extension SourceLocationExtensions on SourceLocation {
  Map<String, int> toMap() => {
        'line': line,
        'column': column,
        'offset': offset,
      };
}

extension SourceSpansExtensions on List<PrettySourceSpan> {
  void sortByLocation() {
    return sort((a, b) {
      if (a.start.offset == b.start.offset && a is PrettyLineEnding) {
        if (a == b) {
          return 1;
        }
        return a.sequence > b.sequence ? -1 : 1;
      }
      if (a.start.offset != b.start.offset) {
        return a.start.offset.compareTo(b.start.offset);
      } else if (a.end.offset != b.end.offset) {
        return a.end.offset.compareTo(b.end.offset);
      } else {
        return a.end.line.compareTo(b.end.line);
      }
    });
  }
}

/// Converts [object] to a JSON [String] with a 2 whitespace indent.
String _toPrettyString(Object object) =>
    const JsonEncoder.withIndent('  ').convert(object);

extension ListExtensions<T> on List<T> {
  String toPrettyString() => _toPrettyString(this);

  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }

    return null;
  }
}

extension MapExtensions on Map<dynamic, dynamic> {
  String toPrettyString() => _toPrettyString(this);
}
