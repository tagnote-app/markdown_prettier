import 'package:dart_markdown/dart_markdown.dart';
import 'models/pretty_node.dart';
import 'utils.dart';

/// Transform the Markdown AST to the prettier AST.
class AstTransformer {
  AstTransformer();

  List<PrettyNode> transform(List<Node> nodes) {
    return _iterateNodes(nodes);
  }

  List<PrettyNode> _iterateNodes(List<Node> nodes) {
    final result = <PrettyNode>[];

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final position = SiblingPosition(total: nodes.length, index: i);
      if (node is Text) {
        final segments = splitText(node);
        position.total += segments.length - 1;
        // TODO: The index is wrong!
        for (final segment in segments) {
          result.add(PrettyText(
            text: segment.text,
            start: segment.start,
            end: segment.end,
            position: position,
          ));
        }
      } else if (node is Element) {
        final children = _iterateNodes(node.children);
        result.add(PrettyElement(
          node.type,
          isBlock: node.isBlock,
          attributes: node.attributes,
          children: children,
          position: position,
          markers: node.markers
              .map((e) => PrettyMarker(
                    text: e.text,
                    start: e.start,
                    end: e.end,
                  ))
              .toList(),
          start: node.start,
          end: node.end,
        ));
      } else {
        throw ArgumentError(
          'Unknown Markdown AST node type ${node.runtimeType}',
        );
      }
    }

    return result;
  }
}
