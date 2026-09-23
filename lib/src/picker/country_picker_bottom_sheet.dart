import 'package:flutter/material.dart';

import '../localization/brakzon_messages.dart';
import '../models/country.dart';
import 'country_list_view.dart';

/// Opens the country picker as a modal bottom sheet and returns the
/// selected [Country] (or null if dismissed without a selection).
///
/// This is called internally by `PhoneFormField` when
/// `pickerMode == CountryPickerMode.bottomSheet`, but it's public so you
/// can invoke it yourself from anywhere (e.g. a settings screen) if you
/// want the exact same picker UI outside the field.
Future<Country?> showCountryPickerBottomSheet({
  required BuildContext context,
  required List<Country> countries,
  Country? selectedCountry,
  BrakzonMessages messages = const BrakzonMessages(),
  String? localeCode,
  bool searchEnabled = true,
  CountryItemBuilder? itemBuilder,
  double heightFactor = 0.75,
  ShapeBorder? shape,
  TextDirection? textDirection,
  double flagSize = 28,
}) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
    builder: (context) {
      return Directionality(
        textDirection: textDirection ?? Directionality.of(context),
        child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
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
          ],
        ),
        ),
      );
    },
  );
}
