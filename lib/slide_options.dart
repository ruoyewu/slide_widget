import 'package:slide_widget/slide_item.dart';

enum SlideState { NORMAL, EXPAND }

typedef OnStateChangeCallback = void Function(SlideState state, SlideItem item);

class SlideOptions {
  SlideOptions(
      {this.leading,
      this.trailing,
      this.enableLeadingExpand = false,
      this.enableTrailingExpand = true,
      this.trailingExpandFactor = 1.2,
      this.leadingExpandFactor = 1.2,
      this.trailingOpenFactor = 0.4,
      this.leadingOpenFactor = 0.4,
      this.trailingExpandIndex,
      this.leadingExpandIndex,
      this.onStateChangeCallback, this.enableVibrate = true}) {
    totalLeadingWidth = 0;
    leading.forEach((element) {
      totalLeadingWidth += element.size.width;
    });

    totalTrailingWidth = 0;
    trailing.forEach((element) {
      totalTrailingWidth += element.size.width;
    });
  }

  OnStateChangeCallback onStateChangeCallback;

  List<SlideItem> trailing;
  List<SlideItem> leading;
  int trailingExpandIndex;
  int leadingExpandIndex;
  double trailingOpenFactor;
  double leadingOpenFactor;
  double trailingExpandFactor;
  double leadingExpandFactor;
  bool enableTrailingExpand;
  bool enableLeadingExpand;
  bool enableVibrate;

  double totalLeadingWidth;
  double totalTrailingWidth;
}
