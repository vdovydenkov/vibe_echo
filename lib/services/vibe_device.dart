import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

/// Класс для управления вибросигнализатором
class VibeDevice {
  /// Присутствие вибросигнализации как таковой
  bool _isVibeEnabled     = false;
  /// Умеет ли устройство в управление амплитудой
  bool _isAmpEnabled      = false;
  /// Умеет ли ли управляться кастомными паттернами (пресетами)
  bool _isPatternsEnabled = false;

  VibeDevice._();

  /// Асинхронный фабричный конструктор
  static Future<VibeDevice> create() async {
    var device = VibeDevice._();
    device._isVibeEnabled     = await Vibration.hasVibrator();
    device._isAmpEnabled      = await Vibration.hasAmplitudeControl();
    device._isPatternsEnabled = await Vibration.hasCustomVibrationsSupport();
    return device;
  }

  bool get isVibeEnabled => _isVibeEnabled;
  bool get isAmpEnabled => _isAmpEnabled;
  bool get isPatternsEnabled => _isPatternsEnabled;

  void vibratePreset({required int preset}) {
    switch (preset) {
      case 1:
        Vibration.vibrate(duration: 1000); // вибрация одну секунду: всегда для теста
        debugPrint('duration: 1000');
        break;
      case 2:
        Vibration.vibrate(duration: 2000, amplitude: 96); // средняя сила вибрации
        debugPrint('duration: 2000, amplitude: 96');
        break;
      case 3:
        Vibration.vibrate(pattern: [200, 300, 200, 300, 200, 300]);
        debugPrint('pattern: [200, 300, 200, 300, 200, 300]');
        break;
      case 4:
        Vibration.vibrate(
          pattern: [200, 400, 200, 600, 200, 800, 200, 1000],
          intensities: [50, 128, 200, 250],
        );
        debugPrint('pattern: [200, 400, 200, 600, 200, 800, 200, 1000],\nintensities: [50, 128, 200, 250]');
        break;
      case 5:
        // Готовые паттерны singleShortBuzz, doubleBuzz, heartbeatVibration, emergencyAlert
        Vibration.vibrate(preset: VibrationPreset.emergencyAlert);
        debugPrint('preset: VibrationPreset.emergencyAlert');
        break;
      default:
        Vibration.vibrate(duration: 5000);
        debugPrint('Default case: duration: 5000');
    }
  }
}
