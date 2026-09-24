/// Represents a single dialable country/territory.
///
/// [isoCode] is the 2-letter ISO 3166-1 alpha-2 code (used to derive the
/// flag emoji). [dialCode] is the international calling code *without*
/// the leading `+`. [nameEn] is the default English display name; you can
/// supply a [translations] map (locale code -> name) or a completely custom
/// [BrakzonMessages.countryNameBuilder] to localize names into Farsi,
/// Arabic, Pashto, or anything else — full control is left to the caller.
class Country {
  final String isoCode;
  final String dialCode;
  final String nameEn;
  final Map<String, String> translations;

  /// Optional max national-number length, used only if you opt into the
  /// (very lightweight, fully overridable) built-in length validation.
  final int? maxLength;

  const Country({
    required this.isoCode,
    required this.dialCode,
    required this.nameEn,
    this.translations = const {},
    this.maxLength,
  });

  /// Emoji flag computed from the ISO code (no image assets needed).
  ///
  /// The package's own widgets (the country selector button and the
  /// picker rows) no longer use this — they render a `CircleFlag` from
  /// the `circle_flags` package instead, since flag emoji rendering is
  /// inconsistent across platforms/fonts (notably many Android devices).
  /// [flagEmoji] is kept only for your own custom builders
  /// (`countrySelectorBuilder` / `countryItemBuilder`) that may still
  /// want it.
  String get flagEmoji {
    final code = isoCode.toUpperCase();
    if (code.length != 2) return '🏳️';
    const base = 0x1F1E6;
    final first = base + (code.codeUnitAt(0) - 'A'.codeUnitAt(0));
    final second = base + (code.codeUnitAt(1) - 'A'.codeUnitAt(0));
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  /// Name for a given [localeCode] (e.g. "fa", "ar", "ps"), falling back
  /// to [nameEn] if no translation was provided.
  String nameFor(String? localeCode) {
    if (localeCode == null) return nameEn;
    return translations[localeCode] ?? nameEn;
  }

  /// Full dial code with the leading `+`.
  String get fullDialCode => '+$dialCode';

  Country copyWith({
    String? isoCode,
    String? dialCode,
    String? nameEn,
    Map<String, String>? translations,
    int? maxLength,
  }) {
    return Country(
      isoCode: isoCode ?? this.isoCode,
      dialCode: dialCode ?? this.dialCode,
      nameEn: nameEn ?? this.nameEn,
      translations: translations ?? this.translations,
      maxLength: maxLength ?? this.maxLength,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          other.isoCode == isoCode &&
          other.dialCode == dialCode;

  @override
  int get hashCode => Object.hash(isoCode, dialCode);

  @override
  String toString() => 'Country($isoCode, +$dialCode, $nameEn)';
}
