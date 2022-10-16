import '../builder.dart';
import '../models/pretty_node.dart';

class ThematicBreakBuilder extends MarkdownBuilder {
  @override
  final matchTypes = ['thematicBreak'];

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
