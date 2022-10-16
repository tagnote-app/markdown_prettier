import 'package:dart_markdown/dart_markdown.dart';

import 'builder.dart';
import 'builders/atx_heading_builder.dart';
import 'builders/blockquote_builder.dart';
import 'builders/delimiter_run_builder.dart';
import 'builders/fenced_blockquote_builder.dart';
import 'builders/fenced_code_block_builder.dart';
import 'builders/hard_line_break_builder.dart';
import 'builders/html_block_builder.dart';
import 'builders/indented_code_block_builder.dart';
import 'builders/list_builder.dart';
import 'builders/paragraph_builder.dart';
import 'builders/setext_heading_builder.dart';
import 'builders/simple_elements_builder.dart';
import 'builders/table_builder.dart';
import 'builders/thematic_break_builder.dart';
import 'extensions.dart';
import 'models/errors.dart';
import 'models/pretty_node.dart';
import 'transformer.dart';

extension MarkdownPrettierExtensions on List<Node> {
  /// Parse to pretty Markdown string.
  String pretty({List<MarkdownBuilder>? builders}) {
    return MarkdownPrettier(builders: builders ?? []).parse(this);
  }
}

class MarkdownPrettier implements PrettyNodeVisitor {
  MarkdownPrettier({
    List<MarkdownBuilder> builders = const [],
  }) {
    final defaultBuilders = <MarkdownBuilder>[
      SimpleElementsBuilder(),
      DelimiterRunBuilder(),
      BlockquoteBuilder(),
      ListBuilder(),
      ParagraphBuilder(),
      IndentedCodeBlockBuilder(),
      FencedCodeBlockBuilder(),
      AtxHeadingBuilder(),
      SetextHeadingBuilder(),
      ThematicBreakBuilder(),
      FencedBlockquoteBuilder(),
      HardLineBreakBuilder(),
      HtmlBlockBuilder(),
      TableBuilder(),
    ];

    for (final builder in [...defaultBuilders, ...builders]) {
      for (final type in builder.matchTypes) {
        _builders[type] = builder;
      }
    }
  }

  final _builders = <String, MarkdownBuilder>{};
  final _tree = <_TreeElement>[];

  String parse(List<Node> nodes) {
    _tree
      ..clear()
      ..add(_TreeElement());

    for (final node in AstTransformer().transform(nodes)) {
      node.accept(this);
    }

    /*
    print(
      _tree.single.children.map((e) => e.toMap()).toList().toPrettyString(),
    );
    */
    return _prettyNodesToString(_tree.single.children);
  }

  @override
  bool visitElementBefore(PrettyElement element) {
    final type = element.type;
    final builder = _builders[type];
    if (builder == null) {
      throw NoBuilderFound(type);
    }

    builder.visitElementBefore(element, _tree.last.element);
    _tree.add(_TreeElement(element));

    return true;
  }

  @override
  void visitText(PrettyText text) {
    _tree.last.children.add(text);
  }

  @override
  void visitElementAfter(PrettyElement element) {
    const backslash = r'$';
    final current = _tree.removeLast();
    final parent = _tree.last;
    final builder = _builders[current.type]!;
    final isBlock = builder.isBlock(element);

    final node = PrettyElement(
      element.type,
      attributes: element.attributes,
      markers: [
        ...builder.prettyMarkers(
          element.markers.where((e) => e.text != backslash).toList(),
          element,
          parent.element,
        ),
        ...element.markers.where((e) => e.text == backslash),
      ],
      children: current.children,
      start: element.start,
      end: element.end,
      isBlock: element.isBlock,
      position: element.position,
    );

    if (isBlock && parent.children.isNotEmpty) {
      parent.children.last.writeln();
    }

    parent.children.add(node);
    builder.visitElementAfter(node, parent.type, parent.children);
  }
}

class _TreeElement {
  _TreeElement([this.element]);

  final PrettyElement? element;
  final children = <PrettyNode>[];

  String? get type => element?.type;
}

String _prettyNodesToString(List<PrettyNode> nodes) {
  final textNodes = <PrettySourceSpan>[];

  void loop(List<PrettyNode> nodes) {
    for (final node in nodes) {
      if (node is PrettyText) {
        textNodes.add(node);
      } else if (node is PrettyElement) {
        textNodes
          ..addAll(node.markers)
          ..addAll(node.lineEndings);
        loop(node.children);
      }
    }
  }

  loop(nodes);
  textNodes.sortByLocation();

  return textNodes.map((e) => e.textContent).join();
}
