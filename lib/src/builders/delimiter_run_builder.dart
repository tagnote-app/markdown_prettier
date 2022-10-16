import '../builder.dart';

class DelimiterRunBuilder extends MarkdownBuilder {
  DelimiterRunBuilder();

  @override
  final matchTypes = [
    'strongEmphasis',
    'emphasis',
    'codeSpan',
    'strikethrough',
    'highlight',
    'superscript',
    'subscript',
    'kbd',
  ];
}
