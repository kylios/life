library editor.dart;

import 'dart:html';

import 'package:life/canvas.dart';
import 'package:life/grid.dart';

class Editor {

  Canvas _canvas;
  Grid _grid;

  Editor(this._grid, this._canvas);

  void start() {
    this._canvas.onClick = this._update;
    this._canvas.draw(this._grid);
  }

  void stop() {
    this._canvas.onClick = null;
  }

  void _update(MouseEvent e) {
    int row = e.offset.y ~/ this._canvas.cellHeight;
    int col = e.offset.x ~/ this._canvas.cellWidth;
    var deltas = [
      new Delta(row, col, !this._grid.isOccupied(row, col))
    ];
    this._grid.applyDeltas(deltas);
    this._canvas.draw(this._grid);
  }
}
