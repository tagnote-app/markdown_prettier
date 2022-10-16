import '../builder.dart';
import '../models/pretty_node.dart';

class ParagraphBuilder extends MarkdownBuilder {
  ParagraphBuilder();

  @override
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {
    if (!element.isLastChild && parentType != 'blockquote') {
      element.writeln();
    }

    for (var i = 0; i < element.children.length; i++) {
      final child = element.children[i];
      if (child is! PrettyText) {
        continue;
      }

      // For example
      // https://spec.commonmark.org/0.30/#example-87
      // TODO(Z): Use element.isFirstChild when the splitText is fixed.
      if (i != 0 && RegExp(r'^[-=]+$').hasMatch(child.text)) {
        child.prependSpaces(4);
      }
    }
  }

  @override
  final matchTypes = ['paragraph'];
}
