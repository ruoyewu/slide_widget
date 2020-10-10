library slide_widget;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:slide_widget/slide_item.dart';

class SlideWidget extends StatefulWidget {
  SlideWidget(
      {@required this.child,
      this.leading,
      this.trailing,
      this.enableLeadingExpand = true,
      this.enableTrailingExpand = true,
      this.trailingExpandFactor = 1.3,
      this.leadingExpandFactor = 1.3,
      this.trailingOpenFactor = 0.4,
      this.leadingOpenFactor = 0.4});

  double trailingOpenFactor;
  double leadingOpenFactor;
  double trailingExpandFactor;
  double leadingExpandFactor;
  bool enableTrailingExpand;
  bool enableLeadingExpand;
  List<SlideItem> trailing;
  List<SlideItem> leading;
  Widget child;

  @override
  State<StatefulWidget> createState() {
    return _SlideWidgetState();
  }
}

class _SlideWidgetState extends State<SlideWidget>
    with TickerProviderStateMixin {
  AnimationController _slideController;

  Animation<Offset> _offset;
  Animation<Offset> _leadingOffset;
  Animation<Offset> _trailingOffset;

  GlobalKey _key = GlobalKey();

  Offset _dragExtent = Offset.zero;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(vsync: this);
    _slideController.addListener(() {
      setState(() {
        _dragExtent =
            Offset(_slideController.value * _width, 0) * _dragExtent.dx.sign;
      });
    });
    _updateAnimation(0);
  }

  _updateAnimation(double offset) {
    final sign = offset.sign;
    _offset = _slideController
        .drive(Tween<Offset>(begin: Offset(0, 0), end: Offset(sign, 0)));
    _leadingOffset = _slideController.drive(
        Tween<Offset>(begin: Offset(-1, 0), end: Offset(sign > 0 ? 0 : -1, 0)));
    _trailingOffset = _slideController.drive(
        Tween<Offset>(begin: Offset(1, 0), end: Offset(sign < 0 ? 0 : 1, 0)));
  }

  _onDragDown(DragDownDetails details) {
    _slideController.stop();
  }

  _onDragUpdate(DragUpdateDetails detail) {
    Offset oldExtent = _dragExtent;
    _dragExtent += detail.delta;
    if (oldExtent.dx.sign != _dragExtent.dx.sign) {
      _updateAnimation(_dragExtent.dx);
    }

    setState(() {
      _slideController.value = _dragExtent.dx.abs() / context.size.width;
    });
  }

  _onDragEnd(DragEndDetails details) {
    final sign = _dragExtent.dx.sign;
    var target = 0.0;
    if (sign > 0) {
      // leading
      var totalWidth = 0.0;
      widget.leading.forEach((element) {
        totalWidth += element.size.width;
      });
      final factory = _widthLeading / totalWidth;
      if (factory < widget.leadingOpenFactor) {
        target = 0;
      } else if (factory >= widget.leadingOpenFactor &&
          (factory < widget.leadingExpandFactor ||
              !widget.enableLeadingExpand)) {
        target = totalWidth / _width;
      } else {
        target = 1;
      }
    } else if (sign < 0) {
      // trailing
      var totalWidth = 0.0;
      widget.trailing.forEach((element) {
        totalWidth += element.size.width;
      });
      double factory = _widthTrailing / totalWidth;
      if (factory < widget.trailingOpenFactor) {
        target = 0;
      } else if (factory >= widget.trailingOpenFactor &&
          (factory < widget.trailingExpandFactor ||
              !widget.enableTrailingExpand)) {
        target = totalWidth / _width;
      } else {
        target = 1;
      }
    }

    _slideController.animateTo(target,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    child = Stack(
      key: _key,
      children: <Widget>[
        if (_showLeading)
          SlideTransition(
              position: _leadingOffset,
              child: _SlideWrapperWidget(
                items: widget.leading,
                offset: _widthLeading,
                alignment: _SlideAlignment.RIGHT,
              )),
        if (_showTrailing)
          SlideTransition(
            position: _trailingOffset,
            child: _SlideWrapperWidget(
              items: widget.trailing,
              offset: _widthTrailing,
              alignment: _SlideAlignment.LEFT,
            ),
          ),
        SlideTransition(
          position: _offset,
          child: child,
        )
      ],
    );
    child = GestureDetector(
      onHorizontalDragDown: _onDragDown,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragCancel: () => _onDragEnd(null),
      onHorizontalDragEnd: _onDragEnd,
      child: child,
    );

    child = child;
    return child;
  }

  get _showLeading {
    return _dragExtent != null &&
        _dragExtent.dx > 0 &&
        widget.leading != null &&
        widget.leading.length > 0;
  }

  get _showTrailing {
    return _dragExtent != null &&
        _dragExtent.dx < 0 &&
        widget.trailing != null &&
        widget.trailing.length > 0;
  }

  get _widthLeading {
    return _width * (1 + _leadingOffset.value.dx);
  }

  get _widthTrailing {
    return _width * (1 - _trailingOffset.value.dx);
  }

  get _width {
    return (_key.currentContext?.findRenderObject() as RenderBox)
            ?.size
            ?.width ??
        0.0;
  }
}

enum _SlideAlignment { LEFT, RIGHT }

class _SlideWrapperWidget extends StatefulWidget {
  _SlideWrapperWidget({this.items, this.offset, this.alignment});

  List<SlideItem> items;
  double offset;
  _SlideAlignment alignment;

  @override
  State<StatefulWidget> createState() {
    return _SlideWrapperState();
  }
}

class _SlideWrapperState extends State<_SlideWrapperWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this);
    _offsetAnimation = _controller.drive(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    final factory = _calculateFactory(widget.offset);
    final alignment = _alignmentToAlignment(widget.alignment);

    for (SlideItem item in widget.items) {
      _controller.value = 1;
      children.add(_SlideItemWrapperWidget(
        item: item,
        width: item.size.width * factory,
        alignment: alignment,
      ));
    }
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  _calculateFactory(double width) {
    var totalWidth = 0.0;
    widget.items.forEach((element) {
      totalWidth += element.size.width;
    });
    return width / totalWidth;
  }

  _alignmentToAlignment(_SlideAlignment alignment) {
    switch (alignment) {
      case _SlideAlignment.LEFT:
        return Alignment.centerLeft;
        break;
      case _SlideAlignment.RIGHT:
        return Alignment.centerRight;
        break;
    }
  }
  
}

class _SlideItemWrapperWidget extends StatelessWidget {
  _SlideItemWrapperWidget(
      {this.item, this.width, this.alignment = Alignment.center});

  Alignment alignment;
  SlideItem item;
  double width;

  @override
  Widget build(BuildContext context) {
    Widget child = item.child;
    child = DecoratedBox(
      decoration: BoxDecoration(color: item.color),
      child: SizedBox(
        width: width,
        child: RepaintBoundary(
            child: UnconstrainedBox(
          alignment: alignment,
          child: SizedBox.fromSize(size: item.size, child: child),
        )),
      ),
    );
    return child;
  }
}
