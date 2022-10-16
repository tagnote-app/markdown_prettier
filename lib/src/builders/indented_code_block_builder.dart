import '../builder.dart';
import '../models/pretty_node.dart';

class IndentedCodeBlockBuilder extends MarkdownBuilder {
  IndentedCodeBlockBuilder();

  @override
  final matchTypes = ['indentedCodeBlock'];

  @override
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {
    for (final child in element.children) {
      if (child is! PrettyText) {
        continue;
      }
      child.prependSpaces(4);

      // Remove line ending from last line.
      if (child.isLastChild) {
        child.updateText(child.text.trimRight());
      }
    }

    if (!element.isLastChild) {
      element.writeln();
    }
  }
}
