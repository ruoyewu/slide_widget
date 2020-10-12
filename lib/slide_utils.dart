import 'package:vibration/vibration.dart';

class SlideUtils {
  static vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }
}
