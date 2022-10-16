import '../builder.dart';
import '../models/pretty_node.dart';

class SetextHeadingBuilder extends MarkdownBuilder {
  @override
  final matchTypes = ['setextHeading'];

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    if (markers.first.length < 3) {
      markers.first.updateText(markers.first.text[0] * 3);
    }
    return markers..first.writeln(false);
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
