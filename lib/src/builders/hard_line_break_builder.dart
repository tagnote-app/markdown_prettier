import '../builder.dart';
import '../models/pretty_node.dart';

class HardLineBreakBuilder extends MarkdownBuilder {
  @override
  final matchTypes = ['hardLineBreak'];

  @override
  List<PrettyMarker> prettyMarkers(
    List<PrettyMarker> markers,
    PrettyElement element,
    PrettyElement? parent,
  ) {
    return markers..first.writeln();
  }
}
