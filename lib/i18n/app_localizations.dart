import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'app_strings_en.dart';
import 'app_strings_ru.dart';
import 'app_strings_zh.dart';

class AppLocalizations extends LocalizationsDelegate<AppStrings> {
  const AppLocalizations();

  static const supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('ru'),
  ];

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'zh':
        return AppStringsZh();
      case 'ru':
        return AppStringsRu();
      default:
        return AppStringsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizations old) => false;
}
