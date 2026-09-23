/// Native numeral glyph sets, indexed by ASCII digit value (0-9), for the
/// locales this package ships built-in localization for. Used to *display*
/// phone numbers using the numerals a Farsi/Arabic/Pashto reader expects
/// (e.g. "۹۱۲" instead of "912") while the underlying digits stay plain
/// ASCII everywhere else (validation, `e164`, grouping).
const Map<String, List<String>> nativeNumeralSets = {
  // Persian (Extended Arabic-Indic) digits — Farsi & Pashto.
  'fa': ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'],
  'ps': ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'],
  // Arabic-Indic digits — Arabic. Urdu conventionally keeps Western digits
  // in most modern usage, so it is intentionally left out here (still
  // falls back to plain ASCII); pass your own `nativeDigits` override to
  // `PhoneFormField` if you want otherwise.
  'ar': ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'],
};

/// Looks up the native numeral glyph set for [localeCode], or `null` if
/// [localeCode] isn't one of the locales with a built-in native numeral
/// set (in which case plain ASCII digits should be used/displayed).
List<String>? nativeNumeralsFor(String? localeCode) {
  if (localeCode == null) return null;
  return nativeNumeralSets[localeCode.toLowerCase()];
}

const Map<String, String> _toAsciiDigitMap = {
  // Persian / Extended Arabic-Indic (Farsi, Pashto, Urdu keyboards)
  '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
  '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  // Arabic-Indic (Arabic keyboards)
  '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
  '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  // Devanagari, for completeness
  '०': '0', '१': '1', '२': '2', '३': '3', '४': '4',
  '५': '5', '६': '6', '७': '7', '८': '8', '९': '9',
};

/// Normalizes any native numeral glyph in [input] (Persian, Arabic-Indic,
/// Devanagari) to plain ASCII `0`-`9`. Already-ASCII digits and all other
/// characters pass through unchanged. Use this whenever you read raw text
/// that may contain native digits and need real numeric/ASCII digits back
/// (e.g. before building `e164` or running length validation).
String normalizeToAsciiDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.split('')) {
    buffer.write(_toAsciiDigitMap[rune] ?? rune);
  }
  return buffer.toString();
}
