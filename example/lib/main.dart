import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:brakzon_phone_field/brakzon_phone_field.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF6C5CE7);
    return MaterialApp(
      title: 'Brakzon Phone Field',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF6F5FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final _formKey = GlobalKey<FormState>();

  // Full control: keep your own controller around to read/reset/prefill.
  late final BrakzonController _controller;

  CountryPickerMode _pickerMode = CountryPickerMode.bottomSheet;
  String _localeCode = 'en';
  bool _submitted = false;

  static const _languages = [
    ('en', 'English', '🇺🇸'),
    ('fa', 'فارسی', '🇮🇷'),
    ('ar', 'العربية', '🇸🇦'),
    ('ps', 'پښتو', '🇦🇫'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = BrakzonController(initialNationalNumber: '');
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(scheme: scheme),
                  const SizedBox(height: 24),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Language',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: scheme.primary),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final (code, label, flag) in _languages)
                              ChoiceChip(
                                label: Text('$flag  $label'),
                                selected: _localeCode == code,
                                onSelected: (_) =>
                                    setState(() => _localeCode = code),
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  color: _localeCode == code
                                      ? scheme.onPrimary
                                      : scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                selectedColor: scheme.primary,
                                backgroundColor: scheme.surfaceContainerHighest,
                                side: BorderSide.none,
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Country picker style',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: scheme.primary),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<CountryPickerMode>(
                          segments: const [
                            ButtonSegment(
                              value: CountryPickerMode.bottomSheet,
                              icon: Icon(Icons.vertical_align_bottom),
                              label: Text('Bottom sheet'),
                            ),
                            ButtonSegment(
                              value: CountryPickerMode.dialog,
                              icon: Icon(Icons.web_asset),
                              label: Text('Dialog'),
                            ),
                          ],
                          selected: {_pickerMode},
                          onSelectionChanged: (s) =>
                              setState(() => _pickerMode = s.first),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Your phone number',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The country picker always sits on the left and '
                            'the number always reads left-to-right — even '
                            'in Farsi, Arabic, or Pashto.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.outline),
                          ),
                          const SizedBox(height: 18),
                          PhoneFormField(
                            controller: _controller,
                            pickerMode: _pickerMode,
                            localeCode: _localeCode,
                            messages: BrakzonMessages.forLocale(_localeCode),
                            useBuiltInLengthValidation: true,
                          ),
                          const SizedBox(height: 16),
                          _LivePreview(controller: _controller, scheme: scheme),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Submit'),
                              onPressed: () {
                                setState(() => _submitted = true);
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        content: Text(
                                          '✅ Valid number: '
                                          '${_controller.value.e164}',
                                        ),
                                      ),
                                    );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_submitted)
                    Text(
                      'Try switching language + picker style above, then '
                      'submit again.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.outline),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ColorScheme scheme;
  const _Header({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.phone_iphone, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'brakzon_phone_field',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Global-ready phone input, fully under your control',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LivePreview extends StatelessWidget {
  final BrakzonController controller;
  final ColorScheme scheme;
  const _LivePreview({required this.controller, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleFlag(value.country.isoCode.toLowerCase(), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isEmpty ? 'Live preview will appear here' : value.e164,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
