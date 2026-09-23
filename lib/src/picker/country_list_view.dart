import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

import '../localization/brakzon_messages.dart';
import '../models/country.dart';
import '../utils/numeral_systems.dart';

/// Signature for fully replacing how a single country row is rendered.
typedef CountryItemBuilder = Widget Function(
  BuildContext context,
  Country country,
  bool selected,
  VoidCallback onTap,
);

/// The searchable list used by both the bottom sheet and dialog pickers.
/// Exposed publicly in case you want to embed it in your own custom
/// picker surface (e.g. a full-screen page) instead of using either
/// built-in presentation.
class CountryListView extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final ValueChanged<Country> onSelected;
  final BrakzonMessages messages;
  final String? localeCode;
  final bool searchEnabled;
  final CountryItemBuilder? itemBuilder;
  final TextDirection? textDirection;
  final ScrollController? scrollController;

  /// Whether the trailing dial code (`+98`) in each row is rendered using
  /// [localeCode]'s native numeral glyphs (see [PhoneFormField.useNativeDigits]).
  /// Defaults to `true`.
  final bool useNativeDigits;

  /// Overrides/extends which native numeral glyph set is used per locale
  /// code. Merged on top of the built-in [nativeNumeralSets] — same
  /// shape as [PhoneFormField.nativeDigits].
  final Map<String, List<String>> nativeDigits;

  /// Size of the circular flag icon shown next to each country row
  /// (rendered via `circle_flags`).
  final double flagSize;

  const CountryListView({
    super.key,
    required this.countries,
    required this.onSelected,
    this.selectedCountry,
    this.messages = const BrakzonMessages(),
    this.localeCode,
    this.searchEnabled = true,
    this.itemBuilder,
    this.textDirection,
    this.scrollController,
    this.useNativeDigits = true,
    this.nativeDigits = const {},
    this.flagSize = 28,
  });

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  late List<Country> _filtered;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.countries;
        return;
      }
      _filtered = widget.countries.where((c) {
        final name = c.nameFor(widget.localeCode).toLowerCase();
        final nameEn = c.nameEn.toLowerCase();
        final dial = c.dialCode;
        final iso = c.isoCode.toLowerCase();
        return name.contains(q) ||
            nameEn.contains(q) ||
            dial.contains(q.replaceAll('+', '')) ||
            iso.contains(q);
      }).toList();
    });
  }

  /// Resolves which native numeral glyph set (if any) applies for the
  /// current [localeCode] — same lookup [PhoneFormField] does for the
  /// field itself, kept independent here so this view still works when
  /// used standalone.
  List<String>? get _nativeDigitSet {
    if (!widget.useNativeDigits) return null;
    final merged = {...nativeNumeralSets, ...widget.nativeDigits};
    return merged[widget.localeCode?.toLowerCase()];
  }

  /// Purely a *display* transform — never touches [Country.dialCode]
  /// itself, so search/filtering above still matches plain ASCII digits
  /// the user types.
  String _localizeDigits(String input) {
    final digitSet = _nativeDigitSet;
    if (digitSet == null) return input;
    return input.split('').map((ch) {
      final d = int.tryParse(ch);
      return d != null ? digitSet[d] : ch;
    }).join();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    return Directionality(
      textDirection: widget.textDirection ?? Directionality.of(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.searchEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: messages.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: messages.clearSearchTooltip,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          Flexible(
            child: _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text(messages.noResultsFound)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    controller: widget.scrollController,
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final country = _filtered[index];
                      final selected = country == widget.selectedCountry;
                      void select() => widget.onSelected(country);

                      if (widget.itemBuilder != null) {
                        return widget.itemBuilder!(
                            context, country, selected, select);
                      }

                      return ListTile(
                        selected: selected,
                        leading: CircleFlag(
                          country.isoCode.toLowerCase(),
                          size: widget.flagSize,
                        ),
                        title: Text(country.nameFor(widget.localeCode)),
                        trailing: Directionality(
                          // dial code itself always LTR, even inside an
                          // RTL-mirrored row (Farsi/Arabic/Pashto/etc.)
                          textDirection: TextDirection.ltr,
                          child: Text(
                            _localizeDigits('+${country.dialCode}'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        onTap: select,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
