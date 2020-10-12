import 'package:flutter/animation.dart';
import 'package:slide_widget/slide_item.dart';
import 'package:slide_widget/slide_options.dart';

class SlideDimension {
  double _totalWidth;

  SlideDimension(
      {this.items,
      this.expandFactor,
      this.expandIndex = 0,
      this.controller,
      this.requestRefresh,
      this.onStateChanged}) {
    _totalWidth = 0;
    items.forEach((element) {
      _totalWidth += element.size.width;
    });

    controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.reverse:
        case AnimationStatus.forward:
          _isExpanding = true;
          break;
        case AnimationStatus.dismissed:
        case AnimationStatus.completed:
          _isExpanding = false;
          break;
      }
    });
    controller.addListener(() {
      requestRefresh();
    });
    _expandAnimation =
        controller.drive(Tween<double>(begin: animationBegin, end: 1));
  }

  Function onStateChanged;
  Function requestRefresh;
  AnimationController controller;
  List<SlideItem> items;
  double expandFactor;
  int expandIndex;

  /*
	* 分为三种状态，
	* expanding & (expand | not expand)，需要根据当前扩张比例计算，扩张过程中的比例范围为 m ~ 1，m 为原始状态下扩张项与所有项的宽比值
	* expand & not expanding，始终最大
	* not expand & not expanding，原始大小
	*/
  bool _isExpand = false;
  bool _isExpanding = false;

  Animation<double> _expandAnimation;

  List<double> calculateWidth(double offset) {
    List<double> widthList = [];
    final factor = _calculateFactor(offset);

    var remainingWidth = offset;
    for (int i = 0; i < items.length; i++) {
      if (i != expandIndex) {
        final width = items[i].size.width * factor;
        remainingWidth -= width;
        widthList.add(width);
      }
    }
    widthList.insert(expandIndex, remainingWidth);
    return widthList;
  }

  _calculateFactor(double width) {
    final realFactor = width / _totalWidth;
    isExpand = realFactor > expandFactor;
    if (_isExpanding) {
      final value = _expandAnimation.value;
      return width *
          (1 - value) /
          (_totalWidth - items[expandIndex].size.width);
    } else if (_isExpand) {
      return 0;
    } else {
      return realFactor;
    }
  }

  set isExpand(bool value) {
    if (_isExpand != value) {
      onStateChanged(value ? SlideState.EXPAND : SlideState.NORMAL);
      controller.animateTo(value ? 1 : 0);
    }
    _isExpand = value;
  }

  get animationBegin {
    return items[expandIndex].size.width / _totalWidth;
  }
}
