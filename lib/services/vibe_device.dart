// lib/services/vibe_device.dart

import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';
import 'package:logger/logger.dart';

/// Пресеты вибросигнализатора
enum VibePreset {
  startApp,       // Старт приложения
  criticalError,  // Приложение не сможет работать
  // Произвольные пресеты для тестирования
  symb1, symb2, symb3, symb4, symb5,
}

/// Класс для управления вибросигнализатором
class VibeDevice {
  /// Присутствие вибросигнализации как таковой
  bool _isVibeEnabled     = false;
  /// Умеет ли устройство в управление амплитудой
  bool _isAmpEnabled      = false;
  /// Умеет ли ли управляться кастомными паттернами (пресетами)
  bool _isPatternsEnabled = false;

  // Если так и останется null - лог не ведём.
  Logger? selfLogger;

  VibeDevice._();

  /// Асинхронный фабричный конструктор
  static Future<VibeDevice> create() async {
    var device = VibeDevice._();
    device._isVibeEnabled     = await Vibration.hasVibrator();
    device._isAmpEnabled      = await Vibration.hasAmplitudeControl();
    device._isPatternsEnabled = await Vibration.hasCustomVibrationsSupport();
    return device;
  }

  // Геттеры свойств
  bool get isVibeEnabled => _isVibeEnabled;
  bool get isAmpEnabled => _isAmpEnabled;
  bool get isPatternsEnabled => _isPatternsEnabled;

  /// Останавливает вибрацию
  void stop() {
    Vibration.cancel();
  }
  
  /// Вибрация заданными шаблонами
  void vibratePreset({required VibePreset preset}) {
    selfLogger?.i('Vibrate preset ${preset.name}');
    switch (preset) {
      case VibePreset.symb1:
        // Всегда простая вибрация - для тестирования
        Vibration.vibrate(duration: 1000);
        break;
      case VibePreset.symb2:
        // Второй тест на изменение амплитуды
        Vibration.vibrate(duration: 2000, amplitude: 96);
        break;
      case VibePreset.symb3:
        // Сложные вибрации с преимущественно короткими сигналами
        Vibration.vibrate(pattern: [70, 120, 70, 120, 70, 120]);
        break;
      case VibePreset.symb4:
        // Сложные вибрации
        Vibration.vibrate(
          pattern: [100, 400, 100, 200, 100, 400, 100, 200],
          intensities: [50, 128, 200, 250],
        );
        break;
      case VibePreset.symb5:
        // Готовые паттерны из пакета: singleShortBuzz, doubleBuzz, heartbeatVibration, emergencyAlert
        Vibration.vibrate(preset: VibrationPreset.heartbeatVibration);
        break;
      case VibePreset.startApp:
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
