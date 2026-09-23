/// Every user-facing string the package renders lives here — nothing is
/// hardcoded in the widgets. Build one with named constructors for a quick
/// start (`.en()`, `.fa()`, `.ar()`, `.ps()`), or construct/`copyWith` your
/// own with whatever text (or callback) you want for every message,
/// including validation/error text.
class BrakzonMessages {
  /// Hint text shown inside the country search box.
  final String searchHint;

  /// Shown when a search yields no matching country.
  final String noResultsFound;

  /// Title of the picker (dialog title / bottom-sheet header).
  final String pickerTitle;

  /// Error shown when the field is required but left empty.
  final String requiredErrorText;

  /// Error shown when the built-in (opt-in) length validator rejects the
  /// number. Receives the currently-selected country's display name.
  final String Function(String countryName)? invalidNumberErrorBuilder;

  /// Fallback flat error text if [invalidNumberErrorBuilder] is null.
  final String invalidNumberErrorText;

  /// Label shown above/around the national-number input, if you choose to
  /// show one (the widget lets you pass `decoration` directly too — this
  /// is only used by the default decoration when you don't).
  final String phoneNumberLabel;

  /// Tooltip/semantic label for the "clear search" button in the picker.
  final String clearSearchTooltip;

  /// Semantic label announced for the country selector button, receives
  /// the currently selected country's display name.
  final String Function(String countryName) countrySelectorSemanticLabel;

  const BrakzonMessages({
    this.searchHint = 'Search country or code',
    this.noResultsFound = 'No country found',
    this.pickerTitle = 'Select a country',
    this.requiredErrorText = 'Phone number is required',
    this.invalidNumberErrorBuilder,
    this.invalidNumberErrorText = 'Enter a valid phone number',
    this.phoneNumberLabel = 'Phone number',
    this.clearSearchTooltip = 'Clear',
    this.countrySelectorSemanticLabel = _defaultSemanticLabel,
  });

  static String _defaultSemanticLabel(String countryName) =>
      'Selected country: $countryName. Double tap to change.';

  /// Resolves the invalid-number message, preferring the builder if set.
  String invalidNumberMessage(String countryName) =>
      invalidNumberErrorBuilder?.call(countryName) ?? invalidNumberErrorText;

  BrakzonMessages copyWith({
    String? searchHint,
    String? noResultsFound,
    String? pickerTitle,
    String? requiredErrorText,
    String Function(String)? invalidNumberErrorBuilder,
    String? invalidNumberErrorText,
    String? phoneNumberLabel,
    String? clearSearchTooltip,
    String Function(String)? countrySelectorSemanticLabel,
  }) {
    return BrakzonMessages(
      searchHint: searchHint ?? this.searchHint,
      noResultsFound: noResultsFound ?? this.noResultsFound,
      pickerTitle: pickerTitle ?? this.pickerTitle,
      requiredErrorText: requiredErrorText ?? this.requiredErrorText,
      invalidNumberErrorBuilder:
          invalidNumberErrorBuilder ?? this.invalidNumberErrorBuilder,
      invalidNumberErrorText: invalidNumberErrorText ?? this.invalidNumberErrorText,
      phoneNumberLabel: phoneNumberLabel ?? this.phoneNumberLabel,
      clearSearchTooltip: clearSearchTooltip ?? this.clearSearchTooltip,
      countrySelectorSemanticLabel:
          countrySelectorSemanticLabel ?? this.countrySelectorSemanticLabel,
    );
  }

  // ---- Ready-made presets — purely convenience, all fully overridable ----

  factory BrakzonMessages.en() => const BrakzonMessages();

  factory BrakzonMessages.fa() => const BrakzonMessages(
        searchHint: 'جستجوی کشور یا کد',
        noResultsFound: 'کشوری یافت نشد',
        pickerTitle: 'انتخاب کشور',
        requiredErrorText: 'وارد کردن شماره تلفن الزامی است',
        invalidNumberErrorText: 'شماره تلفن معتبر وارد کنید',
        phoneNumberLabel: 'شماره تلفن',
        clearSearchTooltip: 'پاک کردن',
      );

  factory BrakzonMessages.ar() => const BrakzonMessages(
        searchHint: 'ابحث عن الدولة أو الرمز',
        noResultsFound: 'لم يتم العثور على نتائج',
        pickerTitle: 'اختر الدولة',
        requiredErrorText: 'رقم الهاتف مطلوب',
        invalidNumberErrorText: 'أدخل رقم هاتف صحيح',
        phoneNumberLabel: 'رقم الهاتف',
        clearSearchTooltip: 'مسح',
      );

  factory BrakzonMessages.ps() => const BrakzonMessages(
        searchHint: 'هیواد یا کوډ ولټوئ',
        noResultsFound: 'هیڅ هیواد ونه موندل شو',
        pickerTitle: 'هیواد وټاکئ',
        requiredErrorText: 'د تلیفون شمېره اړینه ده',
        invalidNumberErrorText: 'سمه د تلیفون شمېره ولیکئ',
        phoneNumberLabel: 'د تلیفون شمېره',
        clearSearchTooltip: 'پاکول',
      );

  factory BrakzonMessages.ur() => const BrakzonMessages(
        searchHint: 'ملک یا کوڈ تلاش کریں',
        noResultsFound: 'کوئی ملک نہیں ملا',
        pickerTitle: 'ملک منتخب کریں',
        requiredErrorText: 'فون نمبر درکار ہے',
        invalidNumberErrorText: 'درست فون نمبر درج کریں',
        phoneNumberLabel: 'فون نمبر',
        clearSearchTooltip: 'صاف کریں',
      );

  /// Look up a bundled preset by locale code, falling back to English.
  /// Add your own entries to this map wrapper in your app if you support
  /// more languages — this is only a convenience, never a hard dependency.
  static BrakzonMessages forLocale(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'fa':
        return BrakzonMessages.fa();
      case 'ar':
        return BrakzonMessages.ar();
      case 'ps':
        return BrakzonMessages.ps();
      case 'ur':
        return BrakzonMessages.ur();
      default:
        return BrakzonMessages.en();
    }
  }
}
