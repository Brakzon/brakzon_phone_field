import '../utils/numeral_systems.dart';
import 'country.dart';

/// Immutable result value produced by the field: the selected [country]
/// plus the [nationalNumber] the user typed (digits after the dial code,
/// exactly as entered — no formatting applied unless you add your own
/// `inputFormatters`). When a native numeral locale (Farsi/Arabic/Pashto)
/// is active, [nationalNumber] may contain native digit glyphs (e.g.
/// "۹۱۲") purely because that's what's displayed on screen — see
/// [digitsOnly] and [e164] for the always-ASCII form.
class BrakzonNumber {
  final Country country;
  final String nationalNumber;

  const BrakzonNumber({required this.country, required this.nationalNumber});

  /// [nationalNumber] with any native numeral glyphs normalized to plain
  /// ASCII `0`-`9` and every non-digit character stripped.
  String get digitsOnly =>
      normalizeToAsciiDigits(nationalNumber).replaceAll(RegExp(r'[^0-9]'), '');

  /// E.164-ish concatenation in the form `+dialCode + nationalNumber`,
  /// always using plain ASCII digits regardless of which numerals are shown
  /// on screen.
  String get e164 => '+${country.dialCode}$digitsOnly';

  bool get isEmpty => nationalNumber.trim().isEmpty;

  @override
  String toString() => e164;
}
