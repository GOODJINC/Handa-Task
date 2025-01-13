import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:handa/pages/todos.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:handa/theme/theme_provider.dart';
import 'package:handa/providers/date_format_provider.dart';
import 'package:handa/providers/week_start_provider.dart';
import 'package:handa/providers/locale_provider.dart';
import 'package:handa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화 옵션
  );
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DateFormatProvider()),
        ChangeNotifierProvider(create: (_) => WeekStartProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'Handa',
          theme: themeProvider.themeData,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
          ],
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Todos(),
        );
      },
    );
  }
}
