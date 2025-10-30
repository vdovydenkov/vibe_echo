// lib/vibe_language/vibe_language.dart

/// Модуль для парсинга и трансляции всех видов исходных данных в вибросигналы.
/// 
/// Vibrocode (виброкод) - набор специальных тегов, формирующих последовательность вибросигналов
///     ~ - виброкод начинается со знака "тильда"
///     V - вибрация (длительность в мс, интенсивность)
///     P - пауза в миллисекундах
///     R - количество повторов предыдущего набора тегов
///     ~V100.200 P50 V200.200 R2
/// 
/// Vibrosign (вибросимвол) - паттерн: набор вибросигналов, закрепленных за смыслом
library;

import 'package:vibe_echo/core/di.dart';
import 'package:vibe_echo/services/vibe_device.dart';

/// Класс для работы с виброкодом.
/// Виброкод - последовательность тегов, транслируемой в вибросигналы
/// Использует синглтон VibeDevice
/// Может выбросить исключение при getDependency
class Vibrocode {
  // Вибросигнализатор - без него ничего не работает
  // Вынимаем из DI в конструкторе
  late final VibeDevice _vbDev;

  Vibrocode(this._vbDev) {
    // Исключение не отлавливается - без вибросигнализатора класс смысла не имеет
    _vbDev = getDependency<VibeDevice>();
  }

  void perform({required String vibroCode}) {
    vibroCode = vibroCode.trim();

    if (vibroCode.isEmpty) return;

    // Разбираем строку по блокам - сепаратор любое кол-во пробелов
    final List<String> codes = vibroCode
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Префикс кода: V, P, R и т.д.
    String prefix;
    // Предыдущий префикс
    String priorPrefix = '';
    // Счетчик кодов - для лога
    // int    counter = 1;
    // Список для vibration pattern
    List<int> vbPattern = [];

    // Преобразуем набор кодов в список pattern из vibration
    // Список из длительностей пауз и вибраций
    for (var code in codes) {
      prefix = code[0];
      switch (prefix) {
        case 'V':  // Вибрация
          // Разбираем код, вытаскиваем из него число после V
          final match = RegExp(r'V(\d+)')
              .firstMatch(code);
          final int? value = match != null ? int.tryParse(match.group(1)!) : null;

          // Числа не вытащили
          if (value == null) break;

          // Если предыдущее значение не было паузой,
          if (priorPrefix != 'P') {
            // Вставляем паузу по умолчанию
            vbPattern.add(50);
          }
          // Вставляем вибрацию заданной длительности
          vbPattern.add(value);
          break;
      }

      // counter++;
    }

    if (vbPattern.isNotEmpty) {
      _vbDev.vibratePattern(customPattern: vbPattern);
    }
  }
}

