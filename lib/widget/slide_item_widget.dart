import 'package:flutter/widgets.dart';

import '../slide_item.dart';

class SlideItemWrapperWidget extends StatelessWidget {
  SlideItemWrapperWidget(
      {this.item, this.width, this.alignment = Alignment.center, this.color});

  Alignment alignment;
  SlideItem item;
  double width;
  Color color;

  @override
  Widget build(BuildContext context) {
    Widget child = item.child;
    child = DecoratedBox(
      decoration: BoxDecoration(color: color ?? item.color),
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
