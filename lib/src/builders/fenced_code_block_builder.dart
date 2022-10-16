import '../builder.dart';
import '../models/pretty_node.dart';

class FencedCodeBlockBuilder extends MarkdownBuilder {
  FencedCodeBlockBuilder();

  @override
  final matchTypes = ['fencedCodeBlock'];

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    markers = markers.map((e) => e..updateText(e.text.trimLeft())).toList();
    markers.first.writeln();

    if (markers.length == 1) {
      markers.add(PrettyMarker.zeroWidth('```\n', element.end));
    }

    return markers;
  }

  @override
  void visitElementAfter(
      PrettyElement element, String? parentType, List<PrettyNode> siblings) {
    if (!element.isLastChild) {
      element.writeln();
    }
  }
}
