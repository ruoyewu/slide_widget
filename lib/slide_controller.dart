import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:slide_widget/slide_options.dart';

class SlideController {
  AnimationController _animationController;
  Animation<Offset> _offset;
  Animation<Offset> _leadingOffset;
  Animation<Offset> _trailingOffset;
  bool _dragging = false;
  Offset _dragExtent = Offset.zero;
  double _dxSign = 0;

  GlobalKey _key = GlobalKey();
  Function _setState;
  BuildContext _context;
  SlideOptions options;

  SlideController init(TickerProvider provider, Function setState,
      BuildContext context, SlideOptions options) {
    this._setState = setState;
    this._context = context;
    this.options = options;

    _animationController = AnimationController(vsync: provider);
    _animationController.addListener(() {
      setState(() {
        if (_dragging) return;
        _dragExtent = Offset(_animationController.value * _width, 0) * _dxSign;
      });
    });
    _updateAnimation(0);
    return this;
  }

  _updateAnimation(double offset) {
    final sign = offset.sign;
    _dxSign = sign;
    _offset = _animationController
        .drive(Tween<Offset>(begin: Offset(0, 0), end: Offset(sign, 0)));
    _leadingOffset = _animationController.drive(
        Tween<Offset>(begin: Offset(-1, 0), end: Offset(sign > 0 ? 0 : -1, 0)));
    _trailingOffset = _animationController.drive(
        Tween<Offset>(begin: Offset(1, 0), end: Offset(sign < 0 ? 0 : 1, 0)));
  }

  onDragDown(DragDownDetails details) {
    _dragging = true;
    _animationController.stop();
  }

  onDragUpdate(DragUpdateDetails detail) {
    _dragExtent += detail.delta;
    if (_dxSign != _dragExtent.dx.sign) {
      _updateAnimation(_dragExtent.dx);
    }

    var maxValue = _context.size.width;
    final sign = _dxSign;
    if ((sign > 0 && !options.enableLeadingExpand) ||
        (sign < 0 && !options.enableTrailingExpand)) {
      final expandFactor =
          sign > 0 ? options.leadingExpandFactor : options.trailingExpandFactor;
      final totalWidth =
          sign > 0 ? options.totalLeadingWidth : options.totalTrailingWidth;
      maxValue = min(sqrt((_dragExtent.dx - totalWidth).abs() * 3) + totalWidth,
          totalWidth * expandFactor - 1);
    }
    _setState(() {
      _animationController.value = min(
          _dragExtent.dx.abs() / _context.size.width,
          maxValue / _context.size.width);
    });
  }

  onDragEnd(DragEndDetails details) {
    _dragging = false;
    final sign = _dxSign;
    var target = 0.0;
    if (sign > 0 || sign < 0) {
      final width = sign > 0 ? widthLeading : widthTrailing;
      final openFactor =
          sign > 0 ? options.leadingOpenFactor : options.trailingOpenFactor;
      final enableExpand =
          sign > 0 ? options.enableLeadingExpand : options.enableTrailingExpand;
      final expandFactor =
          sign > 0 ? options.leadingExpandFactor : options.trailingExpandFactor;

      var totalWidth =
          sign > 0 ? options.totalLeadingWidth : options.totalTrailingWidth;
      final factor = width / totalWidth;
      if (factor < openFactor) {
        target = 0;
      } else if (factor >= openFactor &&
          (factor < expandFactor || !enableExpand)) {
        target = totalWidth / _width;
      } else {
        target = 1;
      }
    }
    _animationController.animateTo(target,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  get showLeading {
    return _dragExtent != null &&
        _dragExtent.dx > 0 &&
        options.leading != null &&
        options.leading.length > 0;
  }

  get showTrailing {
    return _dragExtent != null &&
        _dragExtent.dx < 0 &&
        options.trailing != null &&
        options.trailing.length > 0;
  }

  get leadingOffset => _leadingOffset;

  get trailingOffset => _trailingOffset;

  get offset => _offset;

  get widthLeading {
    return _width * (1 + _leadingOffset.value.dx);
  }

  get widthTrailing {
    return _width * (1 - _trailingOffset.value.dx);
  }

  get _width {
    return (_key.currentContext?.findRenderObject() as RenderBox)
            ?.size
            ?.width ??
        0.0;
  }

  get key => _key;

  void openLeading(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.decelerate}) {
    _prepareAnimation(1);
    _animationController.animateTo(options.totalLeadingWidth / _width,
        duration: duration, curve: curve);
  }

  void openTrailing(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.decelerate}) {
    _prepareAnimation(-1);
    _animationController.animateTo(options.totalTrailingWidth / _width,
        duration: duration, curve: curve);
  }

  void expandLeading(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.decelerate,
      bool closeVibrate}) {
    _prepareAnimation(1, closeVibrate: closeVibrate ?? true);
    _animationController.animateTo(1, duration: duration, curve: curve);
  }

  void expandTrailing(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.decelerate,
      bool closeVibrate}) {
    _prepareAnimation(-1, closeVibrate: closeVibrate ?? true);
    _animationController.animateTo(1, duration: duration, curve: curve);
  }

  void closeLeading(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.decelerate,
      bool closeVibrate}) {
    _prepareAnimation(1, closeVibrate: closeVibrate ?? true);
    _animationController.animateTo(0, duration: duration, curve: curve);
  }

  void closeTrailing(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.decelerate,
      bool closeVibrate}) {
    _prepareAnimation(-1, closeVibrate: closeVibrate ?? true);
    _animationController.animateTo(0, duration: duration, curve: curve);
  }

  bool _prepareAnimation(double sign, {bool closeVibrate = false}) {
    _updateAnimation(sign);

    if (closeVibrate && options.enableVibrate) {
      options.enableVibrate = false;
      AnimationStatusListener statusListener;
      statusListener = (AnimationStatus status) {
        if (status == AnimationStatus.dismissed ||
            status == AnimationStatus.completed) {
          options.enableVibrate = true;
          _animationController.removeStatusListener(statusListener);
        }
      };
      _animationController.addStatusListener(statusListener);
    }
  }
}
