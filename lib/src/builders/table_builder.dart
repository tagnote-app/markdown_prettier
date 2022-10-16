import '../builder.dart';
import '../models/pretty_node.dart';

/// The minimum cell width, the spaces around (`|`) are not count in.
const _cellWidth = 3;

class TableBuilder extends MarkdownBuilder {
  @override
  final matchTypes = [
    'table',
    'tableHead',
    'tableBody',
    'tableRow',
    'tableHeadCell',
    'tableBodyCell',
  ];

  // It does not need to have a table stack, because table cannot be nested.
  final List<_Row> _rows = [];
  final List<_CellSettings> _cellSettings = [];

  @override
  bool isBlock(PrettyElement element) => false;

  @override
  void visitElementAfter(
    PrettyElement element,
    String? parentType,
    List<PrettyNode> siblings,
  ) {
    if (element.type == 'table') {
      _rows.clear();
      _cellSettings.clear();
      _calculateTableCells(element);

      for (var i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        final isLastRow = i + 1 == _rows.length;

        for (var k = 0; k < row.cells.length; k++) {
          final cell = row.cells[k];
          final setting = _cellSettings[k];
          final element = cell.element;
          final isFirstColumn = k == 0;
          final isLastColumn = k + 1 == row.cells.length;

          final spaces = setting.width - cell.width;
          var leadingSpaces = 0;
          var trailingSpaces = 0;
          if (spaces > 0) {
            switch (setting.align) {
              case 'right':
                leadingSpaces = spaces;
                trailingSpaces = 0;
                break;
              case 'center':
                leadingSpaces = (spaces / 2).ceil();
                trailingSpaces = spaces - leadingSpaces;
                break;
              default:
                leadingSpaces = 0;
                trailingSpaces = spaces;
            }
          }

          final leftMarker = PrettyMarker.zeroWidth(
            isFirstColumn ? '| ' : '',
            element.start,
          );

          final rightMarker = PrettyMarker.zeroWidth(' |', element.end);
          if (!isLastColumn) {
            rightMarker.appendSpace();
          } else if (isLastColumn && !isLastRow) {
            rightMarker.writeln();
          }

          leftMarker.appendSpaces(leadingSpaces);
          rightMarker.prependSpaces(trailingSpaces);
          element.markers.addAll([leftMarker, rightMarker]);
        }
      }

      _prettyTableMarker(element.markers.single);

      if (!element.isLastChild) {
        element.writeln();
      }
    }
  }

  void _prettyTableMarker(PrettyMarker marker) {
    final buffer = StringBuffer();
    if (_rows.length == 1) {
      buffer.writeln();
    }
    for (var i = 0; i < _cellSettings.length; i++) {
      final setting = _cellSettings[i];
      final align = setting.align;
      var leftColon = '';
      var rightColon = '';
      switch (align) {
        case 'right':
          rightColon = ':';
          break;
        case 'center':
          leftColon = ':';
          rightColon = ':';
          break;
      }
      final dashes = setting.width - leftColon.length - rightColon.length;

      if (i == 0) {
        buffer.write('| ');
      }
      if (leftColon.isNotEmpty) {
        buffer.write(leftColon);
      }
      buffer.write('-' * dashes);
      if (rightColon.isNotEmpty) {
        buffer.write(rightColon);
      }

      if (i + 1 == _cellSettings.length) {
        buffer.write(' |');
      } else {
        buffer.write(' | ');
      }
    }
    if (_rows.length > 1) {
      buffer.writeln();
    }
    marker.updateText(buffer.toString());
  }

  void _calculateTableCells(PrettyElement element) {
    final headRow = (element.children.first as PrettyElement).children.single;

    for (final headCell in (headRow as PrettyElement).children) {
      _cellSettings.add(
        _CellSettings(
          align: (headCell as PrettyElement).attributes['textAlign'],
        ),
      );
    }

    final rows = List<PrettyElement>.from([
      headRow,
      if (element.children.length > 1)
        ...(element.children[1] as PrettyElement).children,
    ]);

    for (final row in rows) {
      row.markers.clear();
      final cells = <_Cell>[];
      final columns = row.children.length;

      for (var i = 0; i < columns; i++) {
        final cell = row.children[i];
        if (cell is! PrettyElement) {
          continue;
        }

        var contentLength = _countTableCellContent(cell);
        if (cell.markers.isNotEmpty) {
          contentLength += cell.markers
              .map((e) => e.textContent.length)
              .reduce((a, b) => a + b);
        }
        if (contentLength > _cellWidth) {
          _cellSettings[i].width = contentLength;
        }

        cells.add(_Cell(cell, contentLength));
      }

      _rows.add(_Row(cells));
    }
  }

  int _countTableCellContent(PrettyElement element, [int length = 0]) {
    for (final item in element.children) {
      if (item is PrettyElement) {
        length += item.markers
            .map((e) => e.textContent.length)
            .reduce((a, b) => a + b);
        length = _countTableCellContent(item, length);
      } else if (item is PrettyText) {
        length += item.textContent.length;
      }
    }
    return length;
  }
}

class _CellSettings {
  _CellSettings({
    this.align,
  });

  int width = _cellWidth;
  final String? align;
}

class _Row {
  _Row(this.cells);
  final List<_Cell> cells;
}

class _Cell {
  _Cell(this.element, this.width);

  final PrettyElement element;
  final int width;
}
