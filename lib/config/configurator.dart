// lib/config/configurator.dart
// Модуль определяет класс Config — синглтон, отвечающий
// за загрузку и предоставление конфигурационных параметров
// приложения.

import 'package:vibe_echo/config/defaults.dart';
import 'package:vibe_echo/config/vibe_options.dart';

class Config {
  // Приватный конструктор — предотвращает создание экземпляров извне
  Config._();

  // Статическое поле с единственным экземпляром класса.
  static final Config instance = Config._();

  /// Загрузка из SharedPreferences
  Future<void> load() async {
    // Пока здесь просто заглушка.
  }

  // Опции вибросигнализации
  VibeOptions? _vbOpt;

  // Геттеры значений.
  // Пока значения из констант, позже будет проверка других источников.

  /// Возвращает путь к HTML-шаблону панели управления.
  String      get cPanelTemplatePath => defaultCPanelTemplatePath;

  /// Возвращает порт, на котором доступна панель управления.
  int         get cPanelPort         => defaultCPanelPort;

  /// Опции вибросигнализации
  VibeOptions get vbOpt              => _vbOpt ??= VibeOptions()
    ..codePrefix = defaultVibroCodePrefix
    ..internalPause = defaultVibroPause;

  /// Имя файла с сохраненными символами
  String get symbolsFilename         => defaultSymbolsFilename;
}

