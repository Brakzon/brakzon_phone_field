# brakzon_phone_field

A fully customizable Flutter phone-number form field.

- **All languages, including RTL** — Farsi (Persian), Arabic, Pashto, Urdu,
  Hebrew and more. The country **picker screen** (search box, country names)
  follows the `localeCode` you pass in. The **field itself** is deliberately
  pinned left-to-right — country selector always on the left, number always
  extending to the right — matching how phone numbers are written
  internationally, regardless of app language. Override with
  `forceTextDirection` if you want the field row mirrored too.
- **Digits, not locale glyphs** — any Persian/Arabic-Indic digits typed are
  normalized to plain ASCII `0`-`9` automatically, and (on by default)
  grouped with plain spaces for readability (e.g. `912 345 6789`) — never
  locale-specific numeral characters or separators. Turn grouping off with
  `groupDigits: false`, or hand `inputFormatters` your own formatters for
  full control.
- **Every message is dynamic** — nothing is hardcoded. `BrakzonMessages`
  holds every string the package shows (search hint, "no results", required
  error, invalid-number error, picker title, tooltips, semantics label) and
  you can override any subset of them, or start from a bundled preset
  (`.en()`, `.fa()`, `.ar()`, `.ps()`, `.ur()`) and `copyWith` the rest.
- **Country picker: bottom sheet *or* dialog, client's choice** — set
  `pickerMode: CountryPickerMode.bottomSheet` or `.dialog` per instance.
  Both are searchable (by name, translated name, ISO code, or dial code).
- **Full control** — an optional `BrakzonController` for external
  read/write access, a custom `validator`, a custom `countries` list,
  builder hooks (`countrySelectorBuilder`, `countryItemBuilder`) to restyle
  the selector button and every list row, custom `inputFormatters`,
  `decoration`, and more. Built-in validation (length-only) is opt-in via
  `useBuiltInLengthValidation` — bring your own for anything stricter.

> **Not published to pub.dev on purpose.** Drop this folder straight into
> your project (or a private git/path dependency) — see below.

## Install (as a local/path or git dependency)

```yaml
dependencies:
  brakzon_phone_field:
    path: ../brakzon_phone_field   # or: git: { url: ..., path: ... }
```

## Basic usage

```dart
import 'package:brakzon_phone_field/brakzon_phone_field.dart';

PhoneFormField(
  pickerMode: CountryPickerMode.bottomSheet, // or CountryPickerMode.dialog
  messages: BrakzonMessages.fa(),         // fully dynamic, editable
  localeCode: 'fa',                          // drives RTL + translated names
  onChanged: (value) => print(value.e164),   // e.g. "+98912xxxxxxx"
)
```

## Full control example

```dart
final controller = BrakzonController(initialNationalNumber: '');

PhoneFormField(
  controller: controller,
  pickerMode: CountryPickerMode.dialog,
  countries: myOwnCountryList,               // fully replaceable
  messages: const BrakzonMessages(
    searchHint: 'Type a country…',
    requiredErrorText: 'This field cannot be empty',
    invalidNumberErrorText: 'That does not look right',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.nationalNumber.length < 6) return 'Too short';
    return null;
  },
  countrySelectorBuilder: (context, country, openPicker) => GestureDetector(
    onTap: openPicker,
    child: Text('${country.flagEmoji} ${country.fullDialCode}'),
  ),
);

// Read/control it from anywhere:
controller.setCountryByIsoCode('IR');
controller.nationalNumber = '9121234567';
print(controller.value.e164);
```

## Package layout

```
lib/
  brakzon_phone_field.dart          # barrel export
  src/
    models/country.dart           # Country model (+ flag emoji, translations)
    models/countries.dart         # default country list + RTL locale set
    models/phone_number.dart      # BrakzonNumber result value (.e164)
    controller/brakzon_controller.dart
    localization/brakzon_messages.dart
    picker/country_picker_mode.dart
    picker/country_list_view.dart       # shared searchable list
    picker/country_picker_bottom_sheet.dart
    picker/country_picker_dialog.dart
    widgets/phone_form_field.dart       # the public widget
example/
  lib/main.dart                   # runnable demo with a language + picker-mode switch
```
