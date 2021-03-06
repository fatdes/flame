import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

import '../extensions/size.dart';
import 'game.dart';
import 'game_loop.dart';

// ignore: prefer_mixin
class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  BuildContext buildContext;
  Game game;
  late GameLoop gameLoop;

  GameRenderBox(this.buildContext, this.game) {
    gameLoop = GameLoop(gameLoopCallback);
    WidgetsBinding.instance!.addTimingsCallback(game.onTimingsCallback);
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    game.onResize(constraints.biggest.toVector2());
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    game.attach(owner, this);

    game.pauseEngineFn = gameLoop.pause;
    game.resumeEngineFn = gameLoop.resume;

    if (game.runOnCreation) {
      gameLoop.start();
    }

    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    game.detach();
    gameLoop.stop();
    _unbindLifecycleListener();
  }

  void gameLoopCallback(double dt) {
    if (!attached) {
      return;
    }
    game.update(dt);
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    game.render(context.canvas);
    context.canvas.restore();
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance!.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }

  // ignore: annotate_overrides
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;
}
