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
  /// timingSequenceList: список длительностей пауз и вибраций в миллисекундах.
  /// amplitudes:         список амплитуд.
  void vibrateList({
    required List<int> timingSequenceList,
    List<int> amplitudes = const [],
  });

  /// "Проиграть" заданный фиксированный пресет
  void vibratePreset({required VibePreset preset});

  /// Готовит список амплитуд:
  /// возвращает гарантированно правильный или пустой список
  List<int> prepareAmplitudes({
    required List<int> amplitudesRaw,
    int size = 0,  // Размер финального списка с амплитудами
  }) {
    List<int> completeAmplitudes = [];

    // Если амплитуды не заданы, а размер задан
    if (amplitudesRaw.isEmpty && size > 0) {
      // Генерируем одинаковую амплитуду для всех сигналов
      // Для этого на каждую паузу ставим амплитуду 0, а на сигнал - амплитуду 255
      for (var i = 0; i < size ~/ 2; i++) {
        completeAmplitudes.add(0);
        completeAmplitudes.add(255);
      }
    } else {
      // Здесь может быть проверка значений списка на диапазон [0..255]
      // А пока просто присваиваем значение переданных амплитуд
      completeAmplitudes = amplitudesRaw;
    }

    return completeAmplitudes;
  }
}
