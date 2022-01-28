import 'package:flutter/cupertino.dart';

class NoFlingScrollPhysics extends AlwaysScrollableScrollPhysics {
  const NoFlingScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  double get minFlingVelocity => double.infinity;

  @override
  double get maxFlingVelocity => 100.0;

  @override
  double get minFlingDistance => double.infinity;


  @override
  NoFlingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoFlingScrollPhysics(parent: buildParent(ancestor));
  }
}

class SlowScrollPhysics extends AlwaysScrollableScrollPhysics {
  const SlowScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final tolerance = this.tolerance;
    if ((velocity.abs() < tolerance.velocity) ||
        (velocity > 0.0 && position.pixels >= position.maxScrollExtent) ||
        (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      friction: 0.045,    // <--- HERE
      tolerance: tolerance,
    );
  }
}