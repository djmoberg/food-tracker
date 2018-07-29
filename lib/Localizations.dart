import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
// import 'package:flutter_localizations/flutter_localizations.dart';

class Loc {
  Loc(this.locale);

  final Locale locale;

  static Loc of(BuildContext context) {
    return Localizations.of<Loc>(context, Loc);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Food Tracker',
      'createAccount': 'Create Account',
      'loggingIn': 'Logging in...',
      'somethingWentWrong': 'Something went wrong',
    },
    'nb': {
      'title': 'Matsporing',
      'createAccount': 'Ny bruker',
      'loggingIn': 'Logger inn...',
      'somethingWentWrong': 'Noe gikk galt',
    },
  };

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }

  String get createAccount {
    return _localizedValues[locale.languageCode]['createAccount'];
  }

  String get loggingIn {
    return _localizedValues[locale.languageCode]['loggingIn'];
  }

  String get somethingWentWrong {
    return _localizedValues[locale.languageCode]['somethingWentWrong'];
  }
}

class LocDelegate extends LocalizationsDelegate<Loc> {
  const LocDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'nb'].contains(locale.languageCode);

  @override
  Future<Loc> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of Loc.
    return SynchronousFuture<Loc>(Loc(locale));
  }

  @override
  bool shouldReload(LocDelegate old) => false;
}
