## Markdown prettier

A markdown prettier library written in Dart.

## Usage

### Parse a string input

```dart
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
```

output:

```markdown
| abc | defghi |
| :-: | -----: |
| bar |    baz |
```

### Parse a Markdown AST input

```dart
import 'package:dart_markdown/dart_markdown.dart';
import 'package:markdown_prettier/markdown_prettier.dart';

void main() {
  const text = '''
| abc | defghi |
:-: | -----------:
bar | baz
''';

final nodes = Markdown().parse(text);
final result = MarkdownPrettier().parseNodes(nodes);

print(result);
}
```

### Ues as a Markdown extension

```dart
import 'package:dart_markdown/dart_markdown.dart';
import 'package:markdown_prettier/markdown_prettier.dart';

void main() {
  const text = '''
| abc | defghi |
:-: | -----------:
bar | baz
''';

  final nodes = Markdown().parse(text);
  final result = nodes.pretty();

  print(result);
}
```
