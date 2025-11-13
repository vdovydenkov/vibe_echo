// lib/services/haptics/haptic_advanced.dart

import 'package:vibe_echo/services/haptics/haptic_interface.dart';
import 'package:advanced_haptics/advanced_haptics.dart';

/// Наследуем класс и переопределяем под простую вибросигнализацию
/// с использованием библиотеки vibration
class HapticAdvanced extends HapticEngine {
  bool _isVibrationAvailable         = false;
  bool _isAdvancedVibrationAvailable = false;

  @override
  /// Жестко фиксируем режим
  String get mode => VibeMode.advanced.name;

  /// Проверяет доступна ли вибрация на устройстве
  @override
  bool get isVibrationAvailable =>
      _isVibrationAvailable;
  /// Доступен ли продвинутый режим
  @override
  bool get isAdvancedVibrationAvailable =>
      _isAdvancedVibrationAvailable;
  
  HapticAdvanced._();

  static Future<HapticEngine> create() async {
    var haptic = HapticAdvanced._();
    // В AdvancedHaptics нет свойства для проверки устройства вибрации
    // Поэтому считаем отсутствие гибкой вибрации отсутствием вибрации вообще.
    haptic._isVibrationAvailable = await AdvancedHaptics.hasCustomHapticsSupport();
    haptic._isAdvancedVibrationAvailable = haptic._isVibrationAvailable;
    return haptic;
  }

  /// Останавливает вибрацию.
  @override
  void stop() {
    AdvancedHaptics.cancel();
    selfLogger?.d('Vibration is stopped.');
  }

  /// "Проиграть" вибрацию из списка:
  /// список длительностей пауз и вибраций в миллисекундах.
  @override
  void vibrateList({required List<int> timingSequenceList}) {
    selfLogger?.d('Vibration of sequence list temporary not available.');
    // selfLogger?.d('Timing sequences list containts ${timingSequenceList.length} items.');
  }

  /// "Проиграть" заданный фиксированный пресет
  @override
  void vibratePreset({required VibePreset preset}) {
    selfLogger?.d('Vibrate preset ${preset.name}');
    switch (preset) {
      case VibePreset.test1:
        AdvancedHaptics.lightTap();
        break;
      case VibePreset.test2:
        AdvancedHaptics.mediumTap();
        break;
      case VibePreset.test3:
        AdvancedHaptics.heavyRumble();
        break;
      case VibePreset.test4:
        AdvancedHaptics.success();
        break;
      case VibePreset.test5:
        AdvancedHaptics.error();
        break;
      case VibePreset.launched:
        // Приложение загружено
        AdvancedHaptics.successBuzz();
        break;
      case VibePreset.criticalError:
        // Критическая ошибка
        AdvancedHaptics.error();
        break;
    }
  }
}  



