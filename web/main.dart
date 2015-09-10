import 'dart:html';

import 'package:life/grid.dart';
import 'package:life/canvas.dart';
import 'package:life/simulation.dart';
import 'package:life/editor.dart';
import 'package:life/client_api.dart';

void main(List<String> args) async {

  int rows = 50;
  int cols = 50;
  int canvasWidth = 250;
  int canvasHeight = 250;
  int cellWidth = canvasWidth ~/ cols;
  int cellHeight = canvasHeight ~/ rows;

  CanvasElement el = document.querySelector('div.application canvas');
  Canvas canvas = new Canvas(el,
    canvasWidth, canvasHeight,
    cellWidth, cellHeight);

  ButtonElement startButton = document.querySelector('#start');
  SelectElement configurationsList = document.querySelector('#configurations');

  List<List<bool>> world =
      new List<List<bool>>.generate(
        rows, (r) => new List<bool>.filled(cols, false));

  Grid grid = new Grid(world);

  Editor e = new Editor(grid, canvas);
  Simulation s = new Simulation(new ConwayRules(), grid, canvas);

  ClientApi api = new ClientApi("http://localhost:8081");
  api.getConfigurations()
    .then((configurations) {
        for (String configuration in configurations) {
          configurationsList.append(new OptionElement(data: configuration, value: configuration));
        }
      });

  startButton.onClick.listen((_) {
      e.stop();
      s.start();
    });

  e.start();
}
