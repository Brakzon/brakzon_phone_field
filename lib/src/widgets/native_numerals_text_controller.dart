import 'package:flutter/widgets.dart';

class NativeNumeralsTextController extends TextEditingController {
  List<String>? nativeDigitSet; // e.g. ['۰','۱',...,'۹'], settable/updatable

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final digits = nativeDigitSet;
    if (digits == null) {
      return super.buildTextSpan(
          context: context, style: style, withComposing: withComposing);
    }
    final displayText = text.split('').map((ch) {
      final d = int.tryParse(ch);
      return d != null ? digits[d] : ch;
    }).join();
    return TextSpan(style: style, text: displayText);
  }
}
