import 'package:flutter/services.dart';

import 'numeral_systems.dart';

/// Converts Persian, Arabic-Indic, and Devanagari digit glyphs the person
/// types into plain ASCII `0`-`9` before anything else in the formatter
/// chain runs. This keeps the *underlying* digits (used for `e164`,
/// grouping, and length validation) simple ASCII regardless of the
/// keyboard/locale the person is typing with — even when
/// [NativeNumeralsDisplayFormatter] re-renders them as native glyphs
/// afterwards purely for display.
class LocalizedDigitsInputFormatter extends TextInputFormatter {
  const LocalizedDigitsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeToAsciiDigits(newValue.text);
    if (normalized == newValue.text) return newValue;
    return newValue.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(
        offset: normalized.length.clamp(0, normalized.length),
      ),
    );
  }
}

/// Inserts a plain space every [groupSize] digits purely for on-screen
/// readability (e.g. "912 345 6789"). Purely visual grouping — the
/// underlying digits stay simple ASCII 0-9; only
/// [NativeNumeralsDisplayFormatter] (applied after this one) changes the
/// on-screen glyphs.
class DigitGroupingInputFormatter extends TextInputFormatter {
  final int groupSize;

  const DigitGroupingInputFormatter({this.groupSize = 3});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % groupSize == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Re-renders plain ASCII `0`-`9` characters already in the field as the
/// native numeral glyphs in [digits] (index `n` holds the glyph for digit
/// `n`) — purely a display transform applied last in the formatter chain,
/// after normalization and grouping. Everything else (spaces, the `+`
/// sign, letters) passes through untouched, and since it's a strict
/// 1-for-1 character swap the text length — and therefore the caret
/// position — never changes.
///
/// The underlying `TextEditingController.text` therefore contains native
/// glyphs while the field is focused/populated in a locale like `fa`,
/// `ar`, or `ps` — use [normalizeToAsciiDigits] (already applied
/// internally by `BrakzonNumber.e164` and the built-in length validator)
/// whenever you need the plain-ASCII digits back out.
class NativeNumeralsDisplayFormatter extends TextInputFormatter {
  final List<String> digits;

  const NativeNumeralsDisplayFormatter(this.digits)
      : assert(digits.length == 10);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final char in newValue.text.split('')) {
      final n = int.tryParse(char);
      buffer.write(n != null ? digits[n] : char);
    }
    final formatted = buffer.toString();
    if (formatted == newValue.text) return newValue;
    // 1:1 character swap only — same length, so the existing selection
    // offsets stay valid as-is.
    return newValue.copyWith(text: formatted);
  }
}
