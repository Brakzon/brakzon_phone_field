# Contributing

Thanks for considering a contribution. This covers the most common ways to help: adding a language, adding/fixing a country, and general code contributions.

## Ways to contribute

- Add or improve a **language** (translations + RTL/native-digit support)
- Add or fix a **country** (dial code, flag, max length, localized name)
- Fix bugs (formatting, cursor jumps, picker behavior, etc.)
- Improve docs, examples, or tests

Open an issue first for anything non-trivial, so we can align before you put in the work. Small fixes (typos, a missing country) can go straight to a PR.

---

## Adding a new language

All user-facing strings live in `BrakzonMessages`. To add a language (e.g. Urdu, `ur`):

1. Open `lib/localization/brakzon_messages.dart`.
2. Add a named constructor for your locale, following the existing ones (e.g. `BrakzonMessages.fa()`):

   ```dart
   const BrakzonMessages.ur()
       : phoneNumberLabel = 'فون نمبر',
         searchHint = 'ملک تلاش کریں',
         noResultsFound = 'کوئی نتیجہ نہیں ملا',
         clearSearchTooltip = 'صاف کریں',
         requiredErrorText = 'یہ خانہ ضروری ہے',
         // ...every other field the base class defines
         ;
   ```

3. Make sure every field on the base `BrakzonMessages` class is filled in — don't leave any defaulting silently to English. If you're not a native speaker, say so in the PR and ask for a review from someone who is; we'd rather merge a flagged draft than a confidently wrong translation.
4. If the locale reads **right-to-left** (Arabic, Farsi, Pashto, Urdu, Hebrew, etc.), add its code to `defaultRtlLocales` in the same area of the codebase if it isn't already there. This only affects the **picker screen** (search box, country names) — the phone field row itself stays LTR by design, so you don't need to touch that.
5. If the locale has its own **native numeral glyphs** (like Farsi ۰-۹ or Arabic ٠-٩) and you want digits displayed in them by default, add an entry to `nativeNumeralSets` in `lib/utils/numeral_systems.dart`:

   ```dart
   'ur': ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'],
   ```

   If a locale should *not* get native digits (many RTL languages still read digits as plain ASCII), just leave it out — callers can always opt in per-instance via `nativeDigits`.
6. Add or update an example in `example/` showing the new locale in use (see existing Farsi example) so it's easy to visually check RTL layout and native digits together.
7. Update the README's list of supported locales.

**Testing checklist for a new language PR:**

- Country names render correctly for the new `localeCode` (`Country.nameFor`)
- Search matches both the localized name and the English name
- If RTL: picker layout mirrors correctly, phone field row does **not**
- If native digits are added: typed digits normalize to ASCII under the hood (`e164` / `digitsOnly` stay plain ASCII) while the field *displays* native glyphs

---

## Adding or fixing a country

Country data lives in `lib/models/countries.dart` (the `defaultCountries` list) and `lib/models/country.dart` (the `Country` model).

When adding a country, please include:

- `isoCode` (ISO 3166-1 alpha-2, uppercase)
- `dialCode` (digits only, no `+`)
- Localized name entries for every locale already supported, plus `nameEn`
- `maxLength` if you can source it reliably (used only when `useBuiltInLengthValidation` is on — leave it `null` if you're not sure rather than guessing)

Double-check the flag renders via `circle_flags` for that ISO code before submitting — a missing flag asset is a common miss.

---

## Code contributions

- Match the existing style: doc comments on public members, explicit types on public APIs.
- Don't hardcode user-facing strings — every string a user can see belongs in `BrakzonMessages`.
- If you touch digit formatting/parsing (`digit_formatters.dart`, `numeral_systems.dart`, or how `BrakzonController` derives `nationalNumber`/`digitsOnly`), keep the invariant that the underlying stored value is **always plain ASCII** — only *display* should ever show native glyphs. Mixing the two is the source of most cursor/parsing bugs in this codebase, so PRs touching this area get extra scrutiny.
- Add a test or example update alongside behavioral changes where practical.

## Submitting a PR

1. Fork and branch from `main`.
2. Keep PRs focused — one language, one bugfix, one feature per PR is easier to review than a bundle.
3. Describe *what* changed and *why* in the PR description; for a new language, note whether you're a native/fluent speaker.
4. Run `flutter analyze` and `flutter test` before opening the PR.

## Reporting bugs / requesting features

Open an issue with:
- Flutter/Dart version
- `localeCode` and `pickerMode` in use, if relevant
- A minimal repro (a `PhoneFormField` snippet is usually enough)

Thanks again — contributions of any size are welcome.