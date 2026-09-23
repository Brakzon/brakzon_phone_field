import 'package:flutter/widgets.dart';

import '../models/countries.dart';
import '../models/country.dart';
import '../models/phone_number.dart';

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

  BrakzonController({
    Country? initialCountry,
    String? initialNationalNumber,
    List<Country>? countries,
  })  : countries = countries ?? defaultCountries,
        _country = initialCountry ??
            (countries ?? defaultCountries).firstWhere(
              (c) => c.isoCode == 'US',
              orElse: () => (countries ?? defaultCountries).first,
            ),
        textController =
            TextEditingController(text: initialNationalNumber ?? '') {
    textController.addListener(notifyListeners);
  }

  Country get country => _country;

  String get nationalNumber => textController.text;

  set nationalNumber(String value) {
    textController.value = textController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    // listener already calls notifyListeners
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
