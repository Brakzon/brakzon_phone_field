import 'package:flutter/material.dart';

import '../localization/brakzon_messages.dart';
import '../models/country.dart';
import 'country_list_view.dart';

/// Opens the country picker as a centered dialog and returns the selected
/// [Country] (or null if dismissed without a selection).
///
/// Called internally by `PhoneFormField` when
/// `pickerMode == CountryPickerMode.dialog`, but public so you can reuse
/// the same picker UI standalone.
Future<Country?> showCountryPickerDialog({
  required BuildContext context,
  required List<Country> countries,
  Country? selectedCountry,
  BrakzonMessages messages = const BrakzonMessages(),
  String? localeCode,
  bool searchEnabled = true,
  CountryItemBuilder? itemBuilder,
  double maxWidth = 420,
  double maxHeight = 560,
  TextDirection? textDirection,
  double flagSize = 28,
}) {
  return showDialog<Country>(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: textDirection ?? Directionality.of(context),
        child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        messages.pickerTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: CountryListView(
                  countries: countries,
                  selectedCountry: selectedCountry,
                  messages: messages,
                  localeCode: localeCode,
                  searchEnabled: searchEnabled,
                  itemBuilder: itemBuilder,
                  textDirection: textDirection,
                  flagSize: flagSize,
                  onSelected: (country) => Navigator.of(context).pop(country),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        ),
      );
    },
  );
}
