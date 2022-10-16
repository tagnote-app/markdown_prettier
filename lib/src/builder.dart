import 'models/pretty_node.dart';

/// A base class for builders.
abstract class MarkdownBuilder {
  /// Called when an element has been reached, before it's children have been
  /// built.
  void visitElementBefore(PrettyElement element, PrettyElement? parent) {}

  /// Called when an element has been reached, after its children have been
  /// parsed.
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {}

  /// If it is a block type Markdown Node.
  bool isBlock(PrettyElement element) => element.isBlock;

  /// Which element types should this builder match.
  List<String> get matchTypes;

  /// Parses the [markers] of a AST Node.
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    return element.markers;
  }
}
