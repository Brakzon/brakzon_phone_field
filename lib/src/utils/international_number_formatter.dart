import 'package:flutter/services.dart';

import '../models/country.dart';
import 'numeral_systems.dart';

/// Runs BEFORE the normal digit formatters.
///
/// If the user types or pastes a number that starts with `+` or `00`
/// (e.g. "+93 70 123 4567" or "0093701234567") it:
///  1. finds the country whose dial code the number starts with,
///  2. reports it through [onCountryDetected] (so the selector button
///     shows the flag + dial code), and
///  3. leaves ONLY the national number in the text field.
///
/// Digits typed in Persian / Arabic-Indic / Devanagari are understood too.
///
/// Dial codes are 1-4 digits long and some are prefixes of others
/// (`1` vs `1809` Dominican Republic vs `1876` Jamaica), so while the digits
/// typed so far could still grow into a longer dial code the formatter waits
/// and keeps the raw `+18` in the field. Call [commit] (the widget does this
/// when the field loses focus) to force a decision for a still-pending value.
class InternationalNumberInputFormatter extends TextInputFormatter {
  /// Countries that share a dial code: which one wins when the currently
  /// selected country is not one of the candidates.
  static const Map<String, String> defaultPreferredIsoByDialCode = {
    '1': 'US', // instead of CA
    '7': 'RU', // instead of KZ
  };

  final List<Country> countries;
  final Country Function() currentCountry;
  final void Function(Country country) onCountryDetected;

  /// The normal formatters (localized digits, grouping, native glyphs...)
  /// applied to whatever is left in the field.
  final List<TextInputFormatter> inner;

  /// dial code (digits only) -> preferred ISO code, see
  /// [defaultPreferredIsoByDialCode].
  final Map<String, String> preferredIsoByDialCode;

  const InternationalNumberInputFormatter({
    required this.countries,
    required this.currentCountry,
    required this.onCountryDetected,
    required this.inner,
    this.preferredIsoByDialCode = defaultPreferredIsoByDialCode,
  });

  /// Digits-only dial code, e.g. '93', '1809'.
  static String _dial(Country c) =>
      c.dialCode.replaceAll(RegExp(r'[^0-9]'), '');

  // Zero-width / bidi control characters that show up in pasted RTL text.
  static final RegExp _invisible =
      RegExp('[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]');

  /// ASCII digits, ASCII '+', no invisible chars, no leading whitespace.
  static String _clean(String input) {
    return normalizeToAsciiDigits(input)
        .replaceAll('＋', '+')
        .replaceAll(_invisible, '')
        .trimLeft();
  }

  TextEditingValue _applyInner(TextEditingValue oldV, TextEditingValue newV) {
    var value = newV;
    for (final f in inner) {
      value = f.formatEditUpdate(oldV, value);
    }
    return value;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _process(oldValue, newValue, force: false) ??
        _applyInner(oldValue, newValue);
  }

  /// Forces a decision for a value that is still "pending" (e.g. the field
  /// holds just `+1` or `+18`). Returns [value] unchanged when it does not
  /// start with `+` / `00` or no country matches.
  TextEditingValue commit(TextEditingValue value) {
    return _process(value, value, force: true) ?? value;
  }

  /// Splits a complete international number such as "+93712345678" or
  /// "0093712345678" into its country and national number, without touching
  /// any text field. Returns `null` when [input] doesn't start with `+` / `00`
  /// or no dial code matches. Used for programmatic values (initial number,
  /// `BrakzonController.nationalNumber = ...`), where nobody is typing.
  ({Country country, String national})? parse(String input) {
    final text = _clean(input);
    final isPlus = text.startsWith('+');
    if (!isPlus && !text.startsWith('00')) return null;
    final digits =
        text.substring(isPlus ? 1 : 2).replaceAll(RegExp(r'[^0-9]'), '');
    final match = _findCountry(digits, force: true);
    if (match == null) return null;
    return (country: match, national: digits.substring(_dial(match).length));
  }

  /// Returns `null` when the text is not an international number.
  TextEditingValue? _process(
    TextEditingValue oldV,
    TextEditingValue newV, {
    required bool force,
  }) {
    final text = _clean(newV.text);
    final isPlus = text.startsWith('+');
    final isZeroZero = text.startsWith('00');
    if (!isPlus && !isZeroZero) return null;

    final prefix = isPlus ? '+' : '00';
    final digits =
        text.substring(prefix.length).replaceAll(RegExp(r'[^0-9]'), '');

    final match = _findCountry(digits, force: force);
    if (match == null) {
      // Still typing the dial code: keep "+" / "00" + digits as-is.
      final pending = '$prefix$digits';
      return TextEditingValue(
        text: pending,
        selection: TextSelection.collapsed(offset: pending.length),
      );
    }

    final national = digits.substring(_dial(match).length);
    onCountryDetected(match);

    return _applyInner(
      oldV,
      TextEditingValue(
        text: national,
        selection: TextSelection.collapsed(offset: national.length),
      ),
    );
  }

  /// Finds the country for the dial code at the start of [digits].
  ///
  /// Returns `null` while the digits could still become a longer dial code
  /// (unless [force]) or when nothing matches.
  Country? _findCountry(String digits, {required bool force}) {
    if (digits.isEmpty) return null;

    if (!force) {
      final couldExtend = countries.any((c) {
        final d = _dial(c);
        return d.length > digits.length && d.startsWith(digits);
      });
      if (couldExtend) return null;
    }

    var maxDial = 0;
    for (final c in countries) {
      final l = _dial(c).length;
      if (l > maxDial) maxDial = l;
    }
    final maxLen = digits.length < maxDial ? digits.length : maxDial;

    // Longest dial code first.
    for (var len = maxLen; len >= 1; len--) {
      final code = digits.substring(0, len);
      final candidates = countries.where((c) => _dial(c) == code).toList();
      if (candidates.isEmpty) continue;
      return _pick(code, candidates);
    }
    return null;
  }

  Country _pick(String code, List<Country> candidates) {
    final current = currentCountry();
    if (candidates.contains(current)) return current;

    final preferredIso = preferredIsoByDialCode[code];
    if (preferredIso != null) {
      for (final c in candidates) {
        if (c.isoCode.toUpperCase() == preferredIso.toUpperCase()) return c;
      }
    }
    return candidates.first;
  }
}
