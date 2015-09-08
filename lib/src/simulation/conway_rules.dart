part of simulation;


/// Implements John Conway's Game of Life rule set
class ConwayRules extends RuleSet {

  Iterable<Delta> evaluate(Grid world) {
    List<Delta> deltas = new List<Delta>();
    world.forEach((int r, int c, bool val) {
        List<Neighbor> neighbors = world.neighbors(r, c);
        if (val) {
          if (neighbors.length < 2 || neighbors.length > 3) {
            deltas.add(new Delta(r, c, false));
          }
          print("Position ($r, $c): occupied=$val, neighbors=${neighbors.length}");
        } else {
          if (neighbors.length == 3) {
            deltas.add(new Delta(r, c, true));
          }
        }
      });

    return deltas;
  }
}
