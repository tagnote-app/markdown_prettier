import 'package:dart_markdown/dart_markdown.dart';
import 'package:markdown_prettier/src/utils.dart';
import 'package:source_span/source_span.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

Text _createText(String text, [int start = 0]) {
  final span = SourceFile.fromString(text).span(start);
  return Text.fromSpan(span);
}

List<Map<String, dynamic>> _listToMap(List<Text> items) {
  return items.map((e) => e.toMap()).toList();
}

void main() {
  group('splitText', () {
    test('empty text', () {
      final actual = splitText(_createText(''));
      final matcher = [
        {
          'text': '',
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 0, 'column': 0, 'offset': 0}
        }
      ];

      expect(_listToMap(actual), matcher);
    });

    test('one line text', () {
      final actual = splitText(_createText('Foo'));
      final matcher = [
        {
          'text': 'Foo',
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 0, 'column': 3, 'offset': 3}
        }
      ];

      expect(_listToMap(actual), matcher);
    });

    test('one line text with a line ending', () {
      final actual = splitText(_createText('Foo\n'));
      final matcher = [
        {
          'text': 'Foo\n',
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 1, 'column': 0, 'offset': 4}
        }
      ];

      expect(_listToMap(actual), matcher);
    });

    test('two lines', () {
      final actual = splitText(_createText('Foo\nbar'));
      final matcher = [
        {
          'text': 'Foo\n',
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 1, 'column': 0, 'offset': 4}
        },
        {
          'text': 'bar',
          'start': {'line': 1, 'column': 0, 'offset': 4},
          'end': {'line': 1, 'column': 3, 'offset': 7}
        }
      ];

      expect(_listToMap(actual), matcher);
    });

    test('two lines with a line ending at last', () {
      final actual = splitText(_createText('Foo\nbar\n'));
      final matcher = [
        {
          'text': 'Foo\n',
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 1, 'column': 0, 'offset': 4}
        },
        {
          'text': 'bar\n',
          'start': {'line': 1, 'column': 0, 'offset': 4},
          'end': {'line': 2, 'column': 0, 'offset': 8}
        }
      ];

      expect(_listToMap(actual), matcher);
    });

    test('start location is not 0', () {
      final actual = splitText(_createText('Foo\nbar\nbaz', 5));
      final matcher = [
        {
          'text': 'ar\n',
          'start': {'line': 1, 'column': 1, 'offset': 5},
          'end': {'line': 2, 'column': 0, 'offset': 8}
        },
        {
          'text': 'baz',
          'start': {'line': 2, 'column': 0, 'offset': 8},
          'end': {'line': 2, 'column': 3, 'offset': 11}
        }
      ];

      expect(_listToMap(actual), matcher);
    });
  });
}
