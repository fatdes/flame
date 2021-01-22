import 'dart:ui';

import '../particles/particle.dart';
import 'component.dart';

/// Base container for [Particle] instances to be attach
/// to a [Component] tree. Could be added either to BaseGame
/// or an implementation of BaseComponent.
/// Proxies [Component] lifecycle hooks to nested [Particle].
class ParticleComponent extends Component {
  Particle particle;

  ParticleComponent({
    required this.particle,
    int? priority,
  }) : super(priority: priority ?? 0);

  /// This [ParticleComponent] will be removed by the BaseGame.
  @override
  bool get shouldRemove => particle.shouldRemove();

  /// Returns progress of the child [Particle].
  ///
  /// Could be used by external code if needed.
  double get progress => particle.progress;

  /// Passes rendering chain down to the inset
  /// [Particle] within this [Component].
  @override
  void render(Canvas canvas) {
    particle.render(canvas);
  }

  /// Passes update chain to child [Particle].
  @override
  void update(double dt) {
    super.update(dt);
    particle.update(dt);
  }
}
