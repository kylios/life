library ruleset;

import 'package:life/grid.dart';

/// Abstracts the definition of the rules of the simulation.
abstract class RuleSet {

  /// Returns an iterable of deltas after evaluating the current state of the
  /// grid.
  Iterable<Delta> evaluate(Grid world);
}