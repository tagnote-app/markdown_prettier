import '../builder.dart';
import '../models/pretty_node.dart';

class HtmlBlockBuilder extends MarkdownBuilder {
  @override
  final matchTypes = ['htmlBlock'];

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
}
