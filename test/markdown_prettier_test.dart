import 'package:dart_markdown/dart_markdown.dart';
import 'package:markdown_prettier/markdown_prettier.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'helpers.dart';

Future<void> main() async {
  await testDirectory('cases');
}

Future<void> testDirectory(String name) async {
  await for (final dataCase in dataCasesUnder(testDirectory: name)) {
    final description =
        '${dataCase.directory}/${dataCase.file}.unit ${dataCase.description}';

    test(description, () {
      var actual = Markdown().parse(dataCase.input).pretty();
      if (actual.isNotEmpty) {
        actual = '$actual\n';
      }

      expect(actual, dataCase.expectedOutput);
    });
  }
}
