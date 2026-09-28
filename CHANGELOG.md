# Changelog

## 1.0.0

* Initial release.
* Fully customizable Flutter phone-number form field.
* International country selection.
* Country search and selection.
* Localization support.
* RTL language support.
* Localized digit support.
* Phone number validation.

## 1.0.1

* bug fixed

## 1.0.2

### Added
* Automatic country detection from international numbers. Typing or pasting a number that starts with `+` or `00` (e.g. `+93 70 123 4567` or `0093701234567`) now puts the dial code in the country selector and leaves only the national number in the field.
* Detection understands Persian, Arabic-Indic, and Devanagari digits, and ignores invisible RTL marks in pasted text.
* Support for dial codes of 1 to 4 digits, including codes that are prefixes of others (`+1` vs `+1809` Dominican Republic vs `+1876` Jamaica). The field waits for more digits instead of cutting the code short, and a still-undecided code is resolved when the field loses focus.
* Shared dial codes: the currently selected country wins if it matches; otherwise `+1` resolves to US and `+7` to Russia.
* `BrakzonController` accepts a full international number as `initialNationalNumber` or via the `nationalNumber` setter (e.g. `+93712345678`): the country is set from the dial code and only the national part is kept in the field.
* New `InternationalNumberInputFormatter`, exported from the package.

### Fixed
* The country selector (flag and dial code) did not update when the country changed, whether from the picker, `setCountry()`, or the controller. `PhoneFormField` now rebuilds on every controller change.
* An initial number like `+93712345678` stayed in the field with the default country (US) selected, producing a wrong `e164` value of `+193712345678`.
* Guarded against updates after the widget is disposed (for example when the picker closes after the widget has left the tree).

### Changed
* `PhoneFormField.inputFormatters` now replaces only the built-in digit formatters. The `+` / `00` country detection always runs first.