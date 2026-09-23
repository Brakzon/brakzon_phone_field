/// How the country picker is presented when the user taps the selector.
/// Chosen entirely by the client via `PhoneFormField.pickerMode`.
enum CountryPickerMode {
  /// Opens as a modal bottom sheet (good for mobile-first layouts).
  bottomSheet,

  /// Opens as a centered dialog (good for tablet/desktop/web layouts).
  dialog,
}
