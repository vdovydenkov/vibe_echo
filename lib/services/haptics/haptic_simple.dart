// lib/services/haptics/haptic_simple.dart

import 'package:vibe_echo/services/haptics/haptic_interface.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

/// Наследуем класс и переопределяем под простую вибросигнализацию
/// с использованием библиотеки vibration
class HapticSimple extends HapticEngine {
  bool _isVibrationAvailable         = false;
  bool _isAdvancedVibrationAvailable = false;

  @override
  /// Жестко фиксируем режим
  String get mode => VibeMode.simple.name;

  /// Проверяет доступна ли вибрация на устройстве
  @override
  bool get isVibrationAvailable =>
      _isVibrationAvailable;
  /// Доступен ли продвинутый режим
  @override
  bool get isAdvancedVibrationAvailable =>
      _isAdvancedVibrationAvailable;
  
  HapticSimple._();

  static Future<HapticEngine> create() async {
    var haptic = HapticSimple._();
    haptic._isVibrationAvailable = await Vibration.hasVibrator();
    haptic._isAdvancedVibrationAvailable = await Vibration.hasCustomVibrationsSupport();
    return haptic;
  }

  /// Останавливает вибрацию.
  @override
  void stop() {
    Vibration.cancel();
    selfLogger?.d('Vibration is stopped.');
  }

  /// "Проиграть" вибрацию из списка:
  /// список длительностей пауз и вибраций в миллисекундах.
  @override
  void vibrateList({
    required List<int> timingSequenceList,
    List<int> amplitudes = const [],
  }) {
    if (!isAdvancedVibrationAvailable) {
      selfLogger?.e('Advanced custom support is not available.');
      return;
    }

    amplitudes = prepareAmplitudes(amplitudesRaw: amplitudes);

    // Пока без амплитуд
    Vibration.vibrate(pattern: timingSequenceList);
    selfLogger?.d('Timing sequences list containts ${timingSequenceList.length} items.');
  }

  /// "Проиграть" заданный фиксированный пресет
  @override
  void vibratePreset({required VibePreset preset}) {
    selfLogger?.d('Vibrate preset ${preset.name}');
    switch (preset) {
      case VibePreset.test1:
        // Всегда простая вибрация - для тестирования
        Vibration.vibrate(duration: 1000);
        break;
      case VibePreset.test2:
        // Второй тест на изменение амплитуды
        Vibration.vibrate(duration: 2000, amplitude: 100);
        break;
      case VibePreset.test3:
        // Сложные вибрации с преимущественно короткими сигналами
        Vibration.vibrate(pattern: [70, 120, 70, 120, 70, 120]);
        break;
      case VibePreset.test4:
        // Сложные вибрации
        Vibration.vibrate(
          pattern: [100, 400, 100, 200, 100, 400, 100, 200],
          intensities: [50, 128, 200, 250],
        );
        break;
      case VibePreset.test5:
        // Готовые паттерны из пакета: singleShortBuzz, doubleBuzz, heartbeatVibration, emergencyAlert
        Vibration.vibrate(preset: VibrationPreset.heartbeatVibration);
        break;
      case VibePreset.launched:
        // Сигнал о загрузке приложения
        Vibration.vibrate(duration: 5000);
        break;
      case VibePreset.criticalError:
        // Критическая ошибка
        Vibration.vibrate(pattern: [100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200]);
        break;
    }
  }
}  

