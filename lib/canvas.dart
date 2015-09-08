library canvas;

import 'dart:html';

import 'package:life/grid.dart';

class Canvas {
  final int width;
  final int height;
  final int cellWidth;
  final int cellHeight;

  CanvasElement _el;

  var onClick = null;

  Canvas(
      this._el,
      this.width, this.height,
      this.cellWidth, this.cellHeight) {
    this._el.attributes['width'] = this.width.toString();
    this._el.attributes['height'] = this.height.toString();
    this._el.style.width = "${this.width}px";
    this._el.style.height = "${this.height}px";

    this._el.onClick.listen((e) {
        if (this.onClick != null) {
          this.onClick(e);
        }
      });
  }

  void draw(Grid grid) {
    CanvasRenderingContext2D ctx = this._el.getContext('2d');
    grid.forEach((int r, int c, bool val) {
      //print("drawing r=$r, c=$c, val=$val");
      ctx.strokeStyle = '#000000';
      if (r == 0) {
        //print("drawing line from ${c * this.cellWidth}, 0 to ${c * this.cellWidth}, ${this.height}");
        Path2D p = new Path2D();
        p.moveTo(c * this.cellWidth, 0);
        p.lineTo(c * this.cellWidth, this.height);
        ctx.stroke(p);
      }
      if (c == 0) {
        //print("drawing line from 0, ${r * this.cellHeight} to ${this.width}, ${r * this.cellHeight}");
        Path2D p = new Path2D();
        p.moveTo(0, r * this.cellHeight);
        p.lineTo(this.width, r * this.cellHeight);
        ctx.stroke(p);
      }
      if (val) {
        ctx.fillStyle = '#000000';
      } else {
        ctx.fillStyle = '#ffffff';
      }
      ctx.beginPath();
      ctx.fillRect(c * this.cellWidth, r * this.cellHeight, this.cellWidth - 1, this.cellHeight - 1);
      ctx.closePath();
      ctx.fill();
    });
  }
}
