# brakzon_phone_field

A fully customizable Flutter phone-number form field.

- **All languages, including RTL** — Farsi (Persian), Arabic, Pashto, Urdu,
  Hebrew and more. The country **picker screen** (search box, country names)
  follows the `localeCode` you pass in. The **field itself** is deliberately
  pinned left-to-right — country selector always on the left, number always
  extending to the right — matching how phone numbers are written
  internationally, regardless of app language. Override with
  `forceTextDirection` if you want the field row mirrored too.
- **Automatic country detection** — type or paste an international number
  starting with `+` or `00` (e.g. `+93 70 123 4567` or `0093701234567`) and
  the dial code moves into the country selector (flag + dial code) while only
  the national number stays in the field. Works with 1–4 digit dial codes and
  with codes that are prefixes of others (`+1` vs `+1809` Dominican Republic
  vs `+1876` Jamaica): the field waits for more digits instead of cutting the
  code short, and resolves a still-undecided code when the field loses focus.
  Shared codes keep the currently selected country if it matches; otherwise
  `+1` resolves to US and `+7` to Russia. Persian, Arabic-Indic and
  Devanagari digits are understood too.
- **Digits you can trust** — digits typed in any script (Persian,
  Arabic-Indic, Devanagari) are normalized to plain ASCII `0`-`9` under the
  hood, so `e164` and validation are always dependable. On by default they are
  grouped with plain spaces for readability (e.g. `912 345 6789`); turn that
  off with `groupDigits: false`. When `localeCode` has a native numeral system
  (`fa`, `ps`, `ar` out of the box) the digits are *displayed* with those
  glyphs (e.g. `۹۱۲ ۳۴۵ ۶۷۸۹`); set `useNativeDigits: false` to always show
  plain ASCII, or pass `nativeDigits` to add or override a locale. Hand
  `inputFormatters` your own formatters for full control (the `+` / `00`
  detection still runs first).
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
  messages: BrakzonMessages.fa(),            // fully dynamic, editable
  localeCode: 'fa',                          // drives RTL + translated names
  onChanged: (value) => print(value.e164),   // e.g. "+98912xxxxxxx"
)
```

## International numbers

Typing or pasting a number with a leading `+` or `00` selects the country
and keeps only the national number in the field:

| Typed / pasted     | Selector | Field         |
|--------------------|----------|---------------|
| `+93 701234567`    | AF +93   | `701 234 567` |
| `0093701234567`    | AF +93   | `701 234 567` |
| `+355 69 123 4567` | AL +355  | `691 234 567` |
| `+1 202 555 0101`  | US +1    | `202 555 0101`|
| `+1 809 555 1234`  | DO +1809 | `555 1234`    |
| `+1 876 555 1234`  | JM +1876 | `555 1234`    |

A bare number without `+` or `00` (e.g. `93701234567`) is ambiguous, so it is
left exactly as typed.

The same works from code — pass a full international number to the
controller and the country is taken from the dial code:

```dart
final controller = BrakzonController(
  initialNationalNumber: '+93712345678', // -> AF +93, field: 712345678
);

controller.nationalNumber = '+98 912 345 6789'; // -> IR +98, field: 9123456789
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
    if (value.digitsOnly.length < 6) return 'Too short';
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

> Use `value.digitsOnly` (always plain ASCII digits) rather than
> `value.nationalNumber` in validators: the latter may contain native
> numeral glyphs or grouping spaces because that is what is shown on screen.

## Package layout

```
lib/
  brakzon_phone_field.dart          # barrel export
  src/
    models/country.dart             # Country model (+ flag emoji, translations)
    models/countries.dart           # default country list + RTL locale set
    models/phone_number.dart        # BrakzonNumber result value (.e164)
    controller/brakzon_controller.dart
    localization/brakzon_messages.dart
    picker/country_picker_mode.dart
    picker/country_list_view.dart         # shared searchable list
    picker/country_picker_bottom_sheet.dart
    picker/country_picker_dialog.dart
    utils/digit_formatters.dart           # digit normalization, grouping, native numerals
    utils/numeral_systems.dart            # native numeral sets per locale
    utils/international_number_formatter.dart  # "+93…" / "00…" country detection
    widgets/phone_form_field.dart         # the public widget
example/
  lib/main.dart                     # runnable demo with a language + picker-mode switch
```