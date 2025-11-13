// lib/service/haptics/haptic_interface.dart
import 'package:logger/logger.dart';

/// Режимы управления вибрацией
enum VibeMode {
  simple,    // Упрощенное управление, библиотека vibration
  advanced,  // Гибкое управление, библиотека advanced_haptics
}

/// Пресеты вибросигнализатора
enum VibePreset {
  launched,       // Старт приложения
  criticalError,  // Приложение не сможет работать
  // Произвольные пресеты для тестирования
  test1, test2, test3, test4, test5,
}

/// Класс, описывающий все свойства и методы вибросигнализатора.
/// Реализуется в зависимости от выбранной библиотеки
/// Регулируется переменной окружения VIBRATION_MODE (simple/advanced)
abstract class HapticEngine {
  /// Режим управления вибрацией: простой (simple) или гибкий (advanced)
  String get mode;

  /// Проверяет доступна ли вибрация на устройстве
  bool get isVibrationAvailable;
  /// Доступен ли продвинутый режим
  bool get isAdvancedVibrationAvailable;

  /// Внутренний логгер.
  /// Если null - то лог не ведётся.
  Logger? selfLogger;
  
  /// Возвращает текстовое значение статуса устройства:
  /// поддерживает ли гибкое управление вибрацией.
  String statusText() => '''
    Устройство ${isAdvancedVibrationAvailable? '': ' не'} поддерживает сложную вибрацию.
    '''.trim();

  /// Останавливает вибрацию.
  void stop();

  /// "Проиграть" вибрацию из списка:
  /// список длительностей пауз и вибраций в миллисекундах.
  void vibrateList({required List<int> timingSequenceList});

  /// "Проиграть" заданный фиксированный пресет
  void vibratePreset({required VibePreset preset});
}
