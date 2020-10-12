library slide_widget;

import 'package:flutter/widgets.dart';
import 'package:slide_widget/slide_controller.dart';
import 'package:slide_widget/slide_options.dart';
import 'package:slide_widget/widget/slide_wrapper_widget.dart';

class SlideWidget extends StatefulWidget {
  SlideWidget({@required this.child, this.options, this.controller});

  SlideController controller;
  SlideOptions options;
  Widget child;

  @override
  State<StatefulWidget> createState() {
    return _SlideWidgetState();
  }
}

class _SlideWidgetState extends State<SlideWidget>
    with TickerProviderStateMixin {
  SlideController _slideController;

  @override
  void initState() {
    super.initState();

    final options = widget.options ?? SlideOptions();
    _slideController = (widget.controller ?? SlideController()).init(this, setState, context, options);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    child = Stack(
      key: controller.key,
      children: <Widget>[
        if (controller.showLeading)
          SlideTransition(
              position: controller.leadingOffset,
              child: LeadingSlideWrapperWidget(
                offset: controller.widthLeading,
                options: options,
                alignment: SlideAlignment.LEFT,
              )),
        if (controller.showTrailing)
          SlideTransition(
            position: controller.trailingOffset,
            child: TrailingSlideWrapperWidget(
              offset: controller.widthTrailing,
              options: options,
              alignment: SlideAlignment.RIGHT,
            ),
          ),
        SlideTransition(
          position: controller.offset,
          child: child,
        )
      ],
    );
    child = GestureDetector(
      onHorizontalDragDown: controller.onDragDown,
      onHorizontalDragUpdate: controller.onDragUpdate,
      onHorizontalDragCancel: () => controller.onDragEnd(null),
      onHorizontalDragEnd: controller.onDragEnd,
      child: child,
    );

    child = child;
    return child;
  }

  SlideOptions get options => _slideController.options;

  SlideController get controller => _slideController;
}
