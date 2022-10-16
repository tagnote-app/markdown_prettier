import 'package:dart_markdown/dart_markdown.dart';
import 'package:source_span/source_span.dart';

import '../extensions.dart';

abstract class PrettyNodeVisitor extends Visitor<PrettyText, PrettyElement> {}

/// Base node class.
abstract class PrettyNode {
  /// The start location of this node.
  SourceLocation get start;

  void accept(PrettyNodeVisitor visitor);

  /// The end location of this node.
  SourceLocation get end;

  /// Outputs the attributes as a `Map`.
  Map<String, dynamic> toMap();

  /// Adds a line ending to this node.
  void writeln([bool append = true]);
}

/// A [PrettyElement] is a [PrettyNode] has a [children] attribute.
class PrettyElement implements PrettyNode {
  PrettyElement(
    this.type, {
    required this.children,
    required this.markers,
    required this.attributes,
    required this.start,
    required this.end,
    required this.isBlock,
    required this.position,
  }) : lineEndings = [];

  final String type;

  final List<PrettyNode> children;
  final List<PrettyMarker> markers;
  final List<PrettyLineEnding> lineEndings;
  final Map<String, String> attributes;
  final bool isBlock;

  @override
  final SourceLocation start;

  @override
  final SourceLocation end;

  /// The position of this node in it's siblings.
  final SiblingPosition position;

  /// If this is the last child.
  bool get isLastChild => position.index + 1 == position.total;

  /// If this is the first child.
  bool get isFirstChild => position.index == 0;

  /// The children and their children.
  List<PrettyNode> getDescendants([bool withMarkers = false]) {
    final result = <PrettyNode>[];
    void loop(List<PrettyNode> nodes) {
      for (final node in nodes) {
        if (node is PrettyElement) {
          if (withMarkers) {
            result.addAll(node.markers);
          }
          loop(node.children);
        } else {
          result.add(node);
        }
      }
    }

    loop(children);
    return result;
  }

  /// Returns all start locations of the descendants of this node.
  List<SourceLocation> startLocations() {
    final result = <SourceLocation>[];

    void loop(List<PrettyNode> nodes) {
      for (final node in nodes) {
        if (node is PrettyElement) {
          loop(node.children);
        } else {
          result.add(node.start);
        }
      }
    }

    loop(children);

    return result..sort((a, b) => a.offset.compareTo(b.offset));
  }

  @override
  void writeln([bool append = true]) {
    if (append) {
      lineEndings.add(PrettyLineEnding(end));
    } else {
      lineEndings.add(PrettyLineEnding(start, false));
    }
  }

  @override
  void accept(PrettyNodeVisitor visitor) {
    if (visitor.visitElementBefore(this)) {
      if (children.isNotEmpty) {
        for (final child in children) {
          child.accept(visitor);
        }
      }
      visitor.visitElementAfter(this);
    }
  }

  @override
  Map<String, dynamic> toMap({
    bool showNull = false,
    bool showEmpty = false,
    bool showRuntimeType = false,
  }) =>
      {
        'type': type,
        'start': start.toMap(),
        'end': end.toMap(),
        'lineEndings': lineEndings.map((e) => e.toMap()).toList(),
        'markers': markers.map((e) => e.toMap()).toList(),
        'children': children.map((e) => e.toMap()).toList(),
      };
}

abstract class PrettySourceSpan extends SourceSpanBase {
  PrettySourceSpan(super.start, super.end, super.text, [this.sequence = 0]);

  final int sequence;
  String get textContent;

  @override
  bool operator ==(Object other) =>
      other is PrettySourceSpan &&
      start == other.start &&
      end == other.end &&
      sequence == sequence;

  @override
  int get hashCode => Object.hash(start, end, sequence);
}

abstract class PrettyTextBase extends PrettySourceSpan implements PrettyNode {
  PrettyTextBase({
    required String text,
    required SourceLocation start,
    required SourceLocation end,
  })  : _updatedText = text,
        _leadingSpaces = '',
        _lineEndings = '',
        _precededLineEndings = '',
        _trailingSpaces = '',
        super(start, end, text);

  PrettyTextBase.zeroWidth(String text, SourceLocation location)
      : _updatedText = text,
        _leadingSpaces = '',
        _lineEndings = '',
        _precededLineEndings = '',
        _trailingSpaces = '',
        super(location, location, '');

  /// Adds a space to the begining of this node.
  void prependSpace() => prependSpaces(1);

  /// Adds a space to the end of this node.
  void appendSpace() => appendSpaces(1);

  /// Adds the given [amount] of spaces to the begining of this node.
  void prependSpaces(int amount) {
    _leadingSpaces += ' ' * amount;
  }

  /// Adds the given [amount] of spaces to the end of this node.
  void appendSpaces(int amount) {
    _trailingSpaces += ' ' * amount;
  }

  /// Changes the text of this node with the given [text].
  void updateText(String text) {
    _updatedText = text;
  }

  /// The leading spaces of this text node.
  String _leadingSpaces;

  /// The trailing spaces of this text node.
  String _trailingSpaces;

  String _lineEndings;
  String _precededLineEndings;

  @override
  void writeln([bool append = true]) {
    if (append) {
      _lineEndings += '\n';
    } else {
      _precededLineEndings += '\n';
    }
  }

  /// The final text to output.
  // Do not create a new `PrettyText` with the changed text, as the length of
  // the new text might be changed.
  String _updatedText;

  /// The composed string of text, leading spaces, trailing spaces and line
  /// endings.
  @override
  String get textContent => '$_precededLineEndings'
      '$_leadingSpaces$_updatedText$_trailingSpaces$_lineEndings';

  @override
  void accept(PrettyNodeVisitor visitor) {}

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'textContent': textContent,
        'start': start.toMap(),
        'end': end.toMap(),
      };
}

/// A [PrettyText] is a [PrettyNode] has a [text] attribute.
class PrettyText extends PrettyTextBase {
  PrettyText({
    required super.text,
    required super.start,
    required super.end,
    required this.position,
  });

  /// The position of this node in it's siblings.
  final SiblingPosition position;

  @override
  void accept(PrettyNodeVisitor visitor) => visitor.visitText(this);

  /// If this is the last child.
  bool get isLastChild => position.index + 1 == position.total;

  /// If this is the first child.
  bool get isFirstChild => position.index == 0;

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'position': position.toMap(),
      };
}

class PrettyMarker extends PrettyTextBase {
  PrettyMarker({
    required super.text,
    required super.start,
    required super.end,
  });

  PrettyMarker.zeroWidth(super.text, super.location) : super.zeroWidth();
}

class PrettyLineEnding extends PrettySourceSpan {
  PrettyLineEnding(
    SourceLocation location, [
    bool following = true,
  ]) : super(location, location, '', following ? 1 : -1);

  Map<String, dynamic> toMap() => {
        'textContent': textContent,
        'location': start.toMap(),
      };

  @override
  String textContent = '\n';
}

/// Creates a [SiblingPosition] which represent the postion of a [PrettyNode]
/// in it's siblings.
class SiblingPosition {
  SiblingPosition({
    this.total = 0,
    this.index = 0,
  });

  int total;
  int index;

  Map<String, dynamic> toMap() => {'index': index, 'total': total};
}
