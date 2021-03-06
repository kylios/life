library grid;

import 'package:life/configuration.dart';

/// Represents a change to a particular cell in the grid
class Delta {
  final int row;
  final int col;
  final bool val;
  Delta(this.row, this.col, this.val);
}

/// Represents a location on the grid
class Neighbor {
  final int row;
  final int col;
  Neighbor(this.row, this.col);
}

class Grid {

  int _rows;
  int _cols;
  List<List<bool>> _world;

  /// Initialize a new grid object by specifying its size
  Grid(this._rows, this._cols) {

    this._world = this._emptyWorld;
  }

  /// Create a new grid from a matrix of cells
  Grid.fromWorld(this._world) {
    this._rows = this._world.length;
    this._cols = this._world[0].length;
  }
   
  /// Initialize a new grid from a configuration
  Grid.fromConfiguration(this._rows, this._cols, Configuration config) {
    this._world = this._emptyWorld;
    config.cells.forEach((String srow, List<int> cols) {
        int row = int.parse(srow);
        for (int col in cols) {
          this._world[row][col] = true;
        }
      });
  }

  /// Create a new empty world.
  List<List<bool>> get _emptyWorld {
    return new List<List<bool>>.generate(this._rows, 
      (r) => new List<bool>.filled(this._cols, false));
  }

  void setGrid(List<List<bool>> world) {
    this._world = new List<List<bool>>.generate(
      world.length,
      (r) => new List<bool>.from(world[r]));
  }

  bool inRange(int r, int c) =>
    r >= 0 && r < this._world.length &&
    c >= 0 && c < this._world[0].length;

  bool isOccupied(int r, int c) =>
    this.inRange(r, c) && this._world[r][c];

  List<Neighbor> neighbors(int r, int c) {
    List<Neighbor> neighbors = new List<Neighbor>();
    for (int row = r - 1; row <= r + 1; row++) {
      for (int col = c - 1; col <= c + 1; col++) {
        if ((row != r || col != c) && this.isOccupied(row, col)) {
          neighbors.add(new Neighbor(row, col));
        }
      }
    }

    return neighbors;
  }

  int get numRows => this._world.length;
  int get numCols => this._world[0].length;

  List<List<bool>> get world =>
    new List<List<bool>>.generate(
      this._world.length,
      (r) => new List<bool>.from(this._world[r]));

  void forEach(void fn(int r, int c, bool val)) {
    for (int r = 0; r < this._world.length; r++) {
      for (int c = 0; c < this._world[0].length; c++) {
        fn(r, c, this._world[r][c]);
      }
    }
  }

  /// Apply deltas to the grid's world
  void applyDeltas(List<Delta> deltas) {
    for (Delta delta in deltas) {
      this._world[delta.row][delta.col] = delta.val;
    }
  }
}