import '../builder.dart';
import '../models/pretty_node.dart';

class FencedBlockquoteBuilder extends MarkdownBuilder {
  @override
  final matchTypes = ['fencedBlockquote'];

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    return markers
      ..first.writeln()
      ..last.writeln(false);
  }
}
