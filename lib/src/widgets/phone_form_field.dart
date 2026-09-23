import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/brakzon_controller.dart';
import '../localization/brakzon_messages.dart';
import '../models/countries.dart';
import '../models/country.dart';
import '../models/phone_number.dart';
import '../picker/country_list_view.dart';
import '../picker/country_picker_bottom_sheet.dart';
import '../picker/country_picker_dialog.dart';
import '../picker/country_picker_mode.dart';
import '../utils/digit_formatters.dart';
import '../utils/numeral_systems.dart';

/// Signature for fully replacing the tappable country-selector button
/// (the flag + dial code area to the side of the input).
typedef CountrySelectorBuilder = Widget Function(
  BuildContext context,
  Country country,
  VoidCallback openPicker,
);

/// A `TextFormField`-style phone number input with:
///  * A tappable country selector (flag + dial code) opening a searchable
///    picker as either a [CountryPickerMode.bottomSheet] or
///    [CountryPickerMode.dialog] — the client's choice.
///  * A fixed left-to-right field layout — the country selector always sits
///    on the left and the number always extends to the right, exactly like
///    international phone-number conventions expect, regardless of the
///    app's language/locale. The country *picker* screen (search box,
///    country names) still follows [localeCode]/[rtlLocales] for Farsi,
///    Arabic, Pashto, Urdu, Hebrew, etc. — only this field's own layout is
///    pinned. Override with [forceTextDirection] if you ever want the
///    field itself mirrored too.
///  * Digits typed in any script (Persian, Arabic-Indic, Devanagari) are
///    normalized to plain ASCII `0`-`9` under the hood — so `e164` and
///    validation are always dependable — and, when [groupDigits] is on
///    (the default), grouped with plain spaces (e.g. "912 345 6789")
///    purely for readability. On top of that, when [localeCode] is a
///    locale with a native numeral system (`fa`, `ar`, `ps` out of the
///    box — see [nativeDigits]), the digits are *displayed* using that
///    locale's native numeral glyphs (e.g. "۹۱۲ ۳۴۵ ۶۷۸۹" for Farsi), the
///    way a reader of that language expects. Set [useNativeDigits] to
///    `false` to always display plain ASCII regardless of locale.
///  * Every user-facing string editable via [messages]
///    (`BrakzonMessages`) — nothing is hardcoded.
///  * Full external control via an optional [controller]
///    (`BrakzonController`), plus builder hooks for the selector button
///    and each country-list row so you can restyle anything.
///
/// Drop it into a `Form` exactly like `TextFormField`:
///
/// ```dart
/// PhoneFormField(
///   pickerMode: CountryPickerMode.bottomSheet,
///   messages: BrakzonMessages.fa(),
///   localeCode: 'fa',
///   onChanged: (value) => print(value.e164),
/// )
/// ```
class PhoneFormField extends StatefulWidget {
  final BrakzonController? controller;
  final List<Country>? countries;
  final String? initialCountryIsoCode;
  final CountryPickerMode pickerMode;
  final BrakzonMessages messages;
  final String? localeCode;
  final Set<String> rtlLocales;

  /// Overrides the field's own layout direction (selector + input row).
  /// Defaults to `TextDirection.ltr` unconditionally — the country
  /// selector on the left, the number growing to the right — regardless
  /// of [localeCode] or the ambient app direction. Set this explicitly if
  /// you actually want the field itself mirrored for RTL.
  final TextDirection? forceTextDirection;
  final bool searchEnabled;
  final bool showFlag;
  final bool showDialCode;
  final bool enabled;
  final bool required;

  /// Groups typed digits with plain spaces every [digitGroupSize] digits
  /// (e.g. "912 345 6789") for readability. Never affects the underlying
  /// digits or introduces locale-specific separators/glyphs. Set to
  /// `false` for a plain, ungrouped digit string.
  final bool groupDigits;

  /// How many digits per group when [groupDigits] is true.
  final int digitGroupSize;

  /// Whether to *display* the typed digits using [localeCode]'s native
  /// numeral glyphs (Farsi/Pashto: ۰-۹, Arabic: ٠-٩) instead of plain
  /// ASCII `0`-`9`, when [localeCode] has one (see [nativeNumeralSets]).
  /// The underlying digits stay plain ASCII either way (`e164`,
  /// `BrakzonNumber.digitsOnly`, length validation) — this only changes
  /// what's rendered in the field. Defaults to `true`.
  final bool useNativeDigits;

  /// Overrides/extends which native numeral glyph set is used per locale
  /// code (see [useNativeDigits]). Merged on top of the built-in
  /// [nativeNumeralSets] — pass e.g. `{'ur': [...]}` to opt Urdu in, or
  /// `{'fa': ['0', ..., '9']}` to opt a locale back out to ASCII.
  final Map<String, List<String>> nativeDigits;

  /// Size of the circular flag icon shown in the country selector and in
  /// each row of the country picker (via `circle_flags`).
  final double flagSize;

  /// Supply your own validator to fully replace the built-in
  /// required/length checks. Receives the current [BrakzonNumber].
  final String? Function(BrakzonNumber? value)? validator;

  /// Opt into a very small built-in length check (uses
  /// `Country.maxLength` when set). Off by default — bring your own
  /// validator for anything more than "is it non-empty".
  final bool useBuiltInLengthValidation;
  final ValueChanged<BrakzonNumber>? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final ValueChanged<String>? onSubmitted;
  final void Function(BrakzonNumber?)? onSaved;
  final AutovalidateMode autovalidateMode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final CountrySelectorBuilder? countrySelectorBuilder;
  final CountryItemBuilder? countryItemBuilder;
  final double pickerHeightFactor;
  final double pickerDialogMaxWidth;
  final double pickerDialogMaxHeight;

  const PhoneFormField({
    super.key,
    this.controller,
    this.countries,
    this.initialCountryIsoCode,
    this.pickerMode = CountryPickerMode.bottomSheet,
    this.messages = const BrakzonMessages(),
    this.localeCode,
    this.rtlLocales = defaultRtlLocales,
    this.forceTextDirection,
    this.searchEnabled = true,
    this.showFlag = true,
    this.showDialCode = true,
    this.enabled = true,
    this.required = true,
    this.groupDigits = true,
    this.digitGroupSize = 3,
    this.useNativeDigits = true,
    this.nativeDigits = const {},
    this.flagSize = 20,
    this.validator,
    this.useBuiltInLengthValidation = false,
    this.onChanged,
    this.onCountryChanged,
    this.onSubmitted,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.decoration,
    this.style,
    this.textInputAction,
    this.inputFormatters,
    this.focusNode,
    this.countrySelectorBuilder,
    this.countryItemBuilder,
    this.pickerHeightFactor = 0.75,
    this.pickerDialogMaxWidth = 420,
    this.pickerDialogMaxHeight = 560,
  });

  @override
  State<PhoneFormField> createState() => _PhoneFormFieldState();
}

class _PhoneFormFieldState extends State<PhoneFormField> {
  late bool _ownsController;
  late BrakzonController _controller;
  late final bool _ownsFocusNode;
  late FocusNode _focusNode;

  List<Country> get _countries => widget.countries ?? defaultCountries;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        BrakzonController(
          countries: _countries,
          initialCountry: widget.initialCountryIsoCode == null
              ? null
              : _countries.firstWhere(
                  (c) =>
                      c.isoCode.toUpperCase() ==
                      widget.initialCountryIsoCode!.toUpperCase(),
                  orElse: () => _countries.first,
                ),
        );
    if (!_ownsController && widget.initialCountryIsoCode != null) {
      _controller.setCountryByIsoCode(widget.initialCountryIsoCode!);
    }
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PhoneFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) _controller.dispose();
      _controller = widget.controller!;
      _ownsController = false;
      _controller.addListener(_handleControllerChanged);
    }
  }

  void _handleControllerChanged() {
    widget.onChanged?.call(_controller.value);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openPicker(
    BuildContext context, {
    required void Function(Country) onPicked,
  }) async {
    // The picker *screen* (search box, country names) still follows the
    // caller's locale for a natural RTL reading experience — only the
    // field row itself is pinned left-to-right (see class doc).
    final pickerDirection = widget.localeCode != null &&
            widget.rtlLocales.contains(widget.localeCode)
        ? TextDirection.rtl
        : null;

    Country? picked;
    if (widget.pickerMode == CountryPickerMode.bottomSheet) {
      picked = await showCountryPickerBottomSheet(
        context: context,
        countries: _countries,
        selectedCountry: _controller.country,
        messages: widget.messages,
        localeCode: widget.localeCode,
        searchEnabled: widget.searchEnabled,
        itemBuilder: widget.countryItemBuilder,
        heightFactor: widget.pickerHeightFactor,
        textDirection: pickerDirection,
        flagSize: widget.flagSize + 8,
      );
    } else {
      picked = await showCountryPickerDialog(
        context: context,
        countries: _countries,
        selectedCountry: _controller.country,
        messages: widget.messages,
        localeCode: widget.localeCode,
        searchEnabled: widget.searchEnabled,
        itemBuilder: widget.countryItemBuilder,
        maxWidth: widget.pickerDialogMaxWidth,
        maxHeight: widget.pickerDialogMaxHeight,
        textDirection: pickerDirection,
        flagSize: widget.flagSize + 8,
      );
    }
    if (picked != null) onPicked(picked);
  }

  String? _defaultValidator(BrakzonNumber? value) {
    final number = value ?? _controller.value;
    if (number.isEmpty) {
      return widget.required ? widget.messages.requiredErrorText : null;
    }
    if (widget.useBuiltInLengthValidation) {
      final maxLength = number.country.maxLength;
      final digits = number.digitsOnly;
      if (maxLength != null && digits.length != maxLength) {
        return widget.messages
            .invalidNumberMessage(number.country.nameFor(widget.localeCode));
      }
    }
    return null;
  }

  Widget _buildSelector(BuildContext context) {
    final nativeDigitSet = _resolveNativeDigitSet();
    final country = _controller.country;
    void open() => _openPicker(context, onPicked: (picked) {
          _controller.setCountry(picked);
          widget.onCountryChanged?.call(picked);
        });

    if (widget.countrySelectorBuilder != null) {
      return widget.countrySelectorBuilder!(context, country, open);
    }

    return InkWell(
      onTap: widget.enabled ? open : null,
      borderRadius: BorderRadius.circular(8),
      child: Semantics(
        button: true,
        label: widget.messages.countrySelectorSemanticLabel(
          country.nameFor(widget.localeCode),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showFlag) ...[
                CircleFlag(country.isoCode.toLowerCase(),
                    size: widget.flagSize),
                const SizedBox(width: 6),
              ],
              if (widget.showDialCode)
                Text(
                  _localizeDigits(country.fullDialCode, nativeDigitSet),
                  style: widget.style ?? Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<String>? _resolveNativeDigitSet() {
    if (!widget.useNativeDigits) return null;
    final merged = {...nativeNumeralSets, ...widget.nativeDigits};
    return merged[widget.localeCode?.toLowerCase()];
  }

  String _localizeDigits(String input, List<String>? digitSet) {
    if (digitSet == null) return input;
    return input.split('').map((ch) {
      final d = int.tryParse(ch);
      return d != null ? digitSet[d] : ch;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    // Always pinned left-to-right by default: country selector on the
    // left, number extending to the right — this is deliberately NOT
    // derived from `localeCode`/ambient locale (see class doc). Pass
    // `forceTextDirection: TextDirection.rtl` yourself if you actually
    // want this specific row mirrored.
    final fieldDirection = widget.forceTextDirection ?? TextDirection.ltr;

    final nativeDigitSet = _resolveNativeDigitSet();

    final defaultFormatters = <TextInputFormatter>[
      const LocalizedDigitsInputFormatter(),
      if (widget.groupDigits)
        DigitGroupingInputFormatter(groupSize: widget.digitGroupSize)
      else
        FilteringTextInputFormatter.digitsOnly,
      // Purely visual: re-renders the (still plain-ASCII-backed) digits
      // using the locale's native numeral glyphs, e.g. Farsi ۰-۹.
      if (nativeDigitSet != null)
        NativeNumeralsDisplayFormatter(nativeDigitSet),
    ];

    return Directionality(
      textDirection: fieldDirection,
      child: FormField<BrakzonNumber>(
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator ?? _defaultValidator,
        onSaved: widget.onSaved,
        initialValue: _controller.value,
        builder: (field) {
          // Keep the FormField's notion of "current value" in sync with
          // the controller so validators always see fresh data.
          if (field.value?.nationalNumber != _controller.nationalNumber ||
              field.value?.country != _controller.country) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) field.didChange(_controller.value);
            });
          }

          final effectiveDecoration = (widget.decoration ??
                  InputDecoration(
                    labelText: widget.messages.phoneNumberLabel,
                    border: const OutlineInputBorder(),
                  ))
              .copyWith(
            errorText: field.errorText,
            prefixIcon: _buildSelector(context),
            // prefix: ,
          );

          return TextField(
            controller: _controller.textController,
            focusNode: _focusNode,
            enabled: widget.enabled,
            style: widget.style,
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr, // digits always render LTR
            inputFormatters: widget.inputFormatters ?? defaultFormatters,
            decoration: effectiveDecoration,
            onSubmitted: widget.onSubmitted,
            onChanged: (_) => field.didChange(_controller.value),
          );
        },
      ),
    );
  }
}
