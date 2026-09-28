import 'package:flutter/widgets.dart';

import '../models/countries.dart';
import '../models/country.dart';
import '../models/phone_number.dart';
import '../utils/international_number_formatter.dart';

/// Gives the caller full programmatic control over a [PhoneFormField]:
/// read/change the selected country, read/change the typed number,
/// listen for changes, or drive the field from outside entirely
/// (e.g. pre-fill from a saved profile, reset on submit, etc.).
///
/// Pass an instance to `PhoneFormField(controller: ...)`. If you don't
/// provide one, the widget creates and owns its own internally.
class BrakzonController extends ChangeNotifier {
  Country _country;
  final TextEditingController textController;
  final List<Country> countries;

  /// [initialNationalNumber] may also be a full international number such as
  /// `+93712345678` or `0093712345678`: the country is then taken from the
  /// dial code (overriding [initialCountry]) and only the national part
  /// (`712345678`) is put in the text field.
  BrakzonController({
    Country? initialCountry,
    String? initialNationalNumber,
    List<Country>? countries,
  }) : this._(
          countries ?? defaultCountries,
          initialCountry,
          initialNationalNumber ?? '',
        );

  BrakzonController._(
    List<Country> list,
    Country? initialCountry,
    String initialText,
  ) : this._parsed(
          list,
          initialCountry ??
              list.firstWhere(
                (c) => c.isoCode == 'US',
                orElse: () => list.first,
              ),
          initialText,
        );

  BrakzonController._parsed(
    List<Country> list,
    Country fallback,
    String initialText,
  )   : countries = list,
        _country = _split(list, fallback, initialText)?.country ?? fallback,
        textController = TextEditingController(
          text: _split(list, fallback, initialText)?.national ?? initialText,
        ) {
    textController.addListener(notifyListeners);
  }

  static ({Country country, String national})? _split(
    List<Country> list,
    Country current,
    String text,
  ) {
    return InternationalNumberInputFormatter(
      countries: list,
      currentCountry: () => current,
      onCountryDetected: (_) {},
      inner: const [],
    ).parse(text);
  }

  Country get country => _country;

  String get nationalNumber => textController.text;

  /// Setting an international number (`+93712345678` / `0093...`) also
  /// switches the country and keeps only the national part in the field.
  set nationalNumber(String value) {
    final split = _split(countries, _country, value);
    var countryChanged = false;
    if (split != null) {
      countryChanged = split.country != _country;
      _country = split.country;
      value = split.national;
    }
    textController.value = textController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    // The text listener notifies when the text changed; make sure a
    // country-only change is announced too.
    if (countryChanged) notifyListeners();
  }

  BrakzonNumber get value =>
      BrakzonNumber(country: _country, nationalNumber: textController.text);

  /// Change the selected country programmatically (e.g. after detecting
  /// the user's locale/region yourself). Does not clear the typed number.
  void setCountry(Country newCountry) {
    if (newCountry == _country) return;
    _country = newCountry;
    notifyListeners();
  }

  /// Look up and select a country by ISO code (e.g. "IR", "AF", "PS"-as-in
  /// Pakistan uses "PK"). No-op if not found in [countries].
  void setCountryByIsoCode(String isoCode) {
    final match = countries.where(
      (c) => c.isoCode.toUpperCase() == isoCode.toUpperCase(),
    );
    if (match.isNotEmpty) setCountry(match.first);
  }

  void clear() {
    textController.clear();
  }

  @override
  void dispose() {
    textController.removeListener(notifyListeners);
    textController.dispose();
    super.dispose();
  }
}
