library editor.dart;

import 'dart:async';
import 'dart:html';

import 'package:life/canvas.dart';
import 'package:life/grid.dart';
import 'package:life/configuration.dart';

class Editor {

  Canvas _canvas;
  Grid _grid;
  int _rows;
  int _cols;
  Completer<Grid> _completer;

  Editor(this._canvas, this._rows, this._cols) {
    this._grid = new Grid(this._rows, this._cols);
  }

  /// Starts the Editor "mode" of the application
  Future<Grid> run() {

    this._completer = new Completer<Grid>();
    
    this._canvas.onClick = this._update;
    this._canvas.draw(this._grid);
    return this._completer.future;
  }

  /// Returns a copy of this Editor's Grid
  /// Changes to this copy will not reflect into the editor
  Grid get grid => new Grid.fromWorld(this._grid.world);

  /// Load a new world from a config file
  void loadConfig(Configuration config) {
    this._grid = new Grid.fromConfiguration(this._rows, this._cols, config);
    this._canvas.draw(this._grid);
  }

  /// Stops the Editor "mode".  The editor can be restarted with a call to run()
  void stop() {
    this._canvas.onClick = null;
    this._completer.complete(this._grid);
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
