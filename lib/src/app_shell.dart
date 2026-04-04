import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'about_constants.dart';
import 'screens/fatal_error_screen.dart';
import 'screens/home_screen.dart';
import 'shortcut_models.dart';
import 'shortcut_store.dart';

class ShortcutApp extends StatelessWidget {
  const ShortcutApp({super.key, required this.store, required this.aboutInfo});

  final ShortcutStore store;
  final AboutInfo aboutInfo;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFD73A23),
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShortcutStore>.value(value: store),
        Provider<AboutInfo>.value(value: aboutInfo),
      ],
      child: MaterialApp(
        title: AboutConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFFFFF8F3),
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: const Color(0xFF23130E),
            displayColor: const Color(0xFF23130E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0xFFF1DED3)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE4D4CB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE4D4CB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class FatalApp extends StatelessWidget {
  const FatalApp({super.key, required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FatalErrorScreen(details: details),
    );
  }
}
