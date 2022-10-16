// Copyright (c) 2011, the Dart project authors.

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

/// Parse and yield data cases (each a [DataCase]) from [path].
Iterable<DataCase> dataCasesInFile({
  required String path,
  String? baseDir,
}) sync* {
  final file = p.basename(path).replaceFirst(RegExp(r'\..+$'), '');
  baseDir ??= p.relative(p.dirname(path), from: p.dirname(p.dirname(path)));

  // Explicitly create a File, in case the entry is a Link.
  final lines = File(path).readAsLinesSync();

  final frontMatter = StringBuffer();

  var i = 0;

  while (!lines[i].startsWith('>>>')) {
    frontMatter.write('${lines[i++]}\n');
  }

  while (i < lines.length) {
    var description = lines[i++].replaceFirst(RegExp(r'>>>\s*'), '').trim();
    final skip = description.startsWith('skip:');
    if (description == '') {
      description = 'line ${i + 1}';
    } else {
      description = 'line ${i + 1}: $description';
    }

    final input = StringBuffer();
    while (!lines[i].startsWith('<<<')) {
      input.writeln(lines[i++]);
    }

    final expectedOutput = StringBuffer();
    while (++i < lines.length && !lines[i].startsWith('>>>')) {
      expectedOutput.writeln(lines[i]);
    }

    final dataCase = DataCase(
      directory: baseDir,
      file: file,
      frontMatter: frontMatter.toString(),
      description: description,
      skip: skip,
      input: input.toString(),
      expectedOutput: expectedOutput.toString(),
    );
    yield dataCase;
  }
}

/// Parse and return data cases (each a [DataCase]) from [directory].
///
/// By default, only read data cases from files with a `.unit` extension. Data
/// cases are read from files located immediately in [directory], or
/// recursively, according to [recursive].
Iterable<DataCase> _dataCases({
  required String directory,
  String extension = 'unit',
  bool recursive = true,
}) {
  final entries =
      Directory(directory).listSync(recursive: recursive, followLinks: false);
  final results = <DataCase>[];
  for (final entry in entries) {
    if (!entry.path.endsWith(extension)) {
      continue;
    }

    final relativeDir =
        p.relative(p.dirname(entry.path), from: p.dirname(directory));

    results.addAll(dataCasesInFile(path: entry.path, baseDir: relativeDir));
  }

  // The API makes no guarantees on order. This is just here for stability in
  // tests.
  results.sort((a, b) {
    final compare = a.directory.compareTo(b.directory);
    if (compare != 0) return compare;

    return a.file.compareTo(b.file);
  });
  return results;
}

Stream<DataCase> dataCasesUnder({
  required String testDirectory,
  String extension = 'unit',
  bool recursive = true,
}) async* {
  final packageUri = Uri.parse(
    'package:markdown_prettier/markdown_prettier.dart',
  );
  final isolateUri = await Isolate.resolvePackageUri(packageUri);
  final markdownLibRoot = p.dirname(isolateUri!.toFilePath());
  final directory =
      p.joinAll([p.dirname(markdownLibRoot), 'test', testDirectory]);
  for (final dataCase in _dataCases(
    directory: directory,
    extension: extension,
    recursive: recursive,
  )) {
    yield dataCase;
  }
}

/// All of the data pertaining to a particular test case, namely the [input] and
/// [expectedOutput].
class DataCase {
  final String directory;
  final String file;

  final String frontMatter;
  final String description;
  final bool skip;
  final String input;
  final String expectedOutput;

  DataCase({
    this.directory = '',
    this.file = '',
    this.frontMatter = '',
    this.description = '',
    this.skip = false,
    required this.input,
    required this.expectedOutput,
  });

  /// A good standard description for `test()`, derived from the data directory,
  /// the particular data file, and the test case description.
  String get testDescription => [directory, file, description].join(' ');
}
