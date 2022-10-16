import '../builder.dart';
import '../models/pretty_node.dart';

class AtxHeadingBuilder extends MarkdownBuilder {
  @override
  final matchTypes = ['atxHeading'];

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    return markers..first.appendSpace();
  }

  @override
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {
    if (!element.isLastChild && parentType != 'blockquote') {
      element.writeln();
    }
  }
}
