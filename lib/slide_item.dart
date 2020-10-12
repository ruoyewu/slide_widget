import 'package:flutter/widgets.dart';

class SlideItem {
  SlideItem(
      {@required this.child,
      @required this.size,
      this.color,
      this.activeColor});

  Color activeColor;
  Color color;
  Size size;
  Widget child;
}
