/// A fully customizable Flutter phone number form field: RTL-ready
/// (Farsi/Persian, Arabic, Pashto, Urdu, Hebrew, ...), every message
/// editable at runtime, and a searchable country picker you can present
/// as a bottom sheet or a dialog.
library brakzon_phone_field;

export 'src/controller/brakzon_controller.dart';
export 'src/localization/brakzon_messages.dart';
export 'src/models/countries.dart' show defaultCountries, defaultRtlLocales;
export 'src/models/country.dart';
export 'src/models/phone_number.dart';
export 'src/picker/country_list_view.dart' show CountryListView, CountryItemBuilder;
export 'src/picker/country_picker_bottom_sheet.dart' show showCountryPickerBottomSheet;
export 'src/picker/country_picker_dialog.dart' show showCountryPickerDialog;
export 'src/picker/country_picker_mode.dart';
export 'src/utils/digit_formatters.dart';
export 'src/utils/numeral_systems.dart';
export 'src/widgets/phone_form_field.dart';
