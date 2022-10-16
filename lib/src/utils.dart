import 'package:dart_markdown/dart_markdown.dart';
import 'package:source_span/source_span.dart';

/// Splits [Text] by the end of line endings.
List<Text> splitText(Text node) {
  final lines = node.text.split(RegExp('(?<=\n)'));
  if (lines.length == 1) {
    return [node];
  }

  final result = <Text>[];
  var start = node.start;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final end = i + 1 < lines.length
        ? SourceLocation(
            start.offset + line.length,
            line: start.line + 1,
            column: 0,
          )
        : node.end;
    final span = Text.fromSpan(SourceSpan(start, end, line));
    start = end;
    result.add(span);
  }

  return result;
}
