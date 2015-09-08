part of simulation;

class Simulation {

  RuleSet _rules;
  Grid _grid;
  Canvas _canvas;

  bool _running = false;

  Simulation(this._rules, this._grid, this._canvas);

  void _drawLoop(_) {
    this.draw();
    if (this._running) {
      window.requestAnimationFrame(this._drawLoop);
    }
  }

  void start() {
    print("simulation started");
    this._running = true;
    this._canvas.onClick = this._update;
    this._drawLoop(null);
  }

  void stop() {
    this._canvas.onClick = null;
    this._running = false;
  }

  void draw() {
    this._canvas.draw(this._grid);
  }

  void _update(dynamic _) {
    var deltas = this._rules.evaluate(this._grid);
    this._grid.applyDeltas(deltas);
    this._canvas.draw(this._grid);
  }
}