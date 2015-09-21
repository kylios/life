library life;

import 'dart:html';

import 'package:life/client_api.dart';
import 'package:life/editor.dart';
import 'package:life/canvas.dart';
import 'package:life/simulation.dart';
import 'package:life/grid.dart';
import 'package:life/configuration.dart';


int ROWS = 50;
int COLS = 50;
int CANVAS_WIDTH = 250;
int CANVAS_HEIGHT = 250;
int CELL_WIDTH = CANVAS_WIDTH ~/ COLS;
int CELL_HEIGHT = CANVAS_HEIGHT ~/ ROWS;


class Life {
	
  ClientApi _api;
  Editor _editor;
  Simulation _simulation;

  Canvas _canvas;
  ButtonElement _startButton;
  ButtonElement _loadButton;
  SelectElement _listSelect;

  /// Construct a new game of life object.
  Life(this._api,
      CanvasElement canvasEl, 
      this._loadButton, this._startButton, 
      this._listSelect) {

    // Create the canvas
    this._canvas = new Canvas(canvasEl,
      CANVAS_WIDTH, CANVAS_HEIGHT,
      CELL_WIDTH, CELL_HEIGHT);
    this._editor = new Editor(this._canvas, ROWS, COLS);

    // Set up button onClick listeners
    this._startButton.onClick.listen((e) => this.startSimulation());
    this._loadButton.onClick.listen((e) async {

        String configuration = this._listSelect.selectedOptions[0].value;
        Configuration config = await this._api.getConfiguration(configuration);

        this.stopSimulation();
        this._editor.loadConfig(config);

        /* await */ startEditor();
      });
  }

  /// Starts this game of life
  void start() {
    this._api.getConfigurations()
      .then((configurations) async {
        for (String configuration in configurations) {
          this._listSelect.append(
            new OptionElement(data: configuration, value: configuration));
        }

        /* await */ startEditor();
      });
  }

  /// Start running the editor.
  dynamic startEditor() async {

    Grid grid = await this._editor.run();

    this._simulation = new Simulation(new ConwayRules(), grid, this._canvas);
    this._simulation.start();

    return null;
  }

  /// Stops the editor.  The simulation will start as long as startEditor() was
  /// called.
  void startSimulation() {
    this._editor.stop();
  }

  void stopSimulation() {
    if (this._simulation != null) {
      this._simulation.stop();
    }
  }
}
