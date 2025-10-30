// lib/config/configurator.dart
// Модуль определяет класс Config — синглтон, отвечающий
// за загрузку и предоставление конфигурационных параметров
// приложения.

import 'package:vibe_echo/config/defaults.dart';

class Config {
  // Приватный конструктор — предотвращает создание
  // экземпляров извне, обеспечивая шаблон Singleton.
  Config._internal();

  // Статическое поле с единственным экземпляром класса.
  static final Config _instance = Config._internal();

  // Публичный геттер, возвращающий единственный экземпляр.
  static Config get instance => _instance;

  // Геттеры значений.
  // Пока значения из констант, позже будет проверка других источников.

  /// Возвращает путь к HTML-шаблону панели управления.
  String get cPanelTemplatePath => defaultCPanelTemplatePath;

  /// Возвращает порт, на котором доступна панель управления.
  int get cPanelPort => defaultCPanelPort;

  /// Возвращает префикс виброкода
  String get vibroCodePrefix => defaultVibroCodePrefix;
}
