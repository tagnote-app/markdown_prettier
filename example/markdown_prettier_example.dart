import 'package:markdown_prettier/markdown_prettier.dart';

void main() {
  const text = '''
| abc | defghi |
:-: | -----------:
bar | baz
''';

  final result = MarkdownPrettier().parse(text);

  print(result);
}
