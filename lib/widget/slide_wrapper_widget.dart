import 'package:flutter/widgets.dart';
import 'package:slide_widget/slide_utils.dart';
import 'package:slide_widget/widget/slide_item_widget.dart';

import '../slide_dimension.dart';
import '../slide_item.dart';
import '../slide_options.dart';

enum SlideAlignment { LEFT, RIGHT }

abstract class SlideWrapperWidget extends StatefulWidget {
  SlideWrapperWidget({this.offset, this.alignment, this.options});

  double offset;
  SlideAlignment alignment;
  SlideOptions options;

  @override
  State<StatefulWidget> createState() {
    return _SlideWrapperState();
  }

  List<SlideItem> get items {
    switch (alignment) {
      case SlideAlignment.LEFT:
        return options.leading;
      case SlideAlignment.RIGHT:
        return options.trailing;
    }
  }

  OnStateChangeCallback get onStateChangeCallback {
    return options.onStateChangeCallback;
  }

  int get expandIndex {
    switch (alignment) {
      case SlideAlignment.LEFT:
        return options.leadingExpandIndex ?? 0;
      case SlideAlignment.RIGHT:
        return options.trailingExpandIndex ?? options.trailing.length - 1;
    }
  }

  double get expandFactor {
    switch (alignment) {
      case SlideAlignment.LEFT:
        return options.leadingExpandFactor;
      case SlideAlignment.RIGHT:
        return options.trailingExpandFactor;
    }
  }
}

class LeadingSlideWrapperWidget extends SlideWrapperWidget {
  LeadingSlideWrapperWidget({offset, alignment, options})
      : super(offset: offset, alignment: alignment, options: options);
}

class TrailingSlideWrapperWidget extends SlideWrapperWidget {
  TrailingSlideWrapperWidget({offset, alignment, options})
      : super(offset: offset, alignment: alignment, options: options);
}

class _SlideWrapperState extends State<SlideWrapperWidget>
    with TickerProviderStateMixin {
  AnimationController _colorAnimationController;
  List<Animation<Color>> _colorAnimations;
  SlideDimension _dimension;

  @override
  void initState() {
    super.initState();
    _dimension = SlideDimension(
        items: widget.items,
        expandIndex: widget.expandIndex,
        expandFactor: widget.expandFactor,
        controller: AnimationController(
            vsync: this, duration: Duration(milliseconds: 200)),
        requestRefresh: () => setState(() => {}),
        onStateChanged: onStateChanged);
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _colorAnimations = List(widget.items.length);
    _colorAnimations[widget.expandIndex] = _colorAnimationController.drive(
        ColorTween(
            begin: widget.items[widget.expandIndex].color,
            end: widget.items[widget.expandIndex].activeColor ??
                widget.items[widget.expandIndex].color));
  }

  void onStateChanged(SlideState state) {
    if (widget.options.enableVibrate) {
      SlideUtils.vibrate();
    }

    if (widget.onStateChangeCallback != null) {
      widget.onStateChangeCallback(state, widget.items[widget.expandIndex]);
    }
    if (state == SlideState.EXPAND) {
      _colorAnimationController.animateTo(1);
    } else {
      _colorAnimationController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    final alignment = _alignmentToAlignment(widget.alignment);
    final widthList = _dimension.calculateWidth(widget.offset);

    for (int i = 0; i < widget.items.length; i++) {
      children.add(SlideItemWrapperWidget(
        item: widget.items[i],
        width: widthList[i],
        alignment: alignment,
        color: _colorAnimations[i]?.value ?? null,
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

  _alignmentToAlignment(SlideAlignment alignment) {
    switch (alignment) {
      case SlideAlignment.LEFT:
        return Alignment.centerRight;
        break;
      case SlideAlignment.RIGHT:
        return Alignment.centerLeft;
        break;
    }
  }
}
