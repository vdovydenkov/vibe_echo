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
import 'package:vibe_echo/config/configurator.dart';
import 'package:vibe_echo/utils/extractors.dart';

/// Класс для работы с виброкодом.
/// Виброкод - последовательность тегов, транслируемой в вибросигналы
/// Использует синглтон VibeDevice
/// Может выбросить исключение при getDependency
class Vibrocode {
  // Вибросигнализатор - без него ничего не работает
  // Вынимаем из DI в конструкторе
  late final VibeDevice _vbDev;

  // Конфигурация - прежде всего, vbOpt
  late final Config     _cfg;

  /// В конструкторе вынемаем VibeDevice и Config из DI
  Vibrocode() {
    // Исключение не отлавливается - без вибросигнализатора класс смысла не имеет
    _vbDev = getDependency<VibeDevice>();
    _cfg   = getDependency<Config>();
  }

  void perform({required String vibroCode, required }) {
    vibroCode = vibroCode.trim();

    if (vibroCode.isEmpty) return;

    // Разбираем строку по блокам - сепаратор любое кол-во пробелов
    final List<String> codes = vibroCode
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Признак кода: V, P, R и т.д.
    String prefix;
    // Предыдущий признак-префикс
    String priorPrefix = '';
    // Предыдущее значение паузы сначала берем по умолчанию
    int priorPause = _cfg.vbOpt.internalPause;

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
          // Извлекаем число после V
          final int? value = extractInt(after: 'V', source: code);

          // Числа не вытащили, уходим
          if (value == null) break;

          // Вставляем текущее значение паузы
          vbPattern.add(priorPause);
          // Вставляем вибрацию заданной длительности
          vbPattern.add(value);
          break;
        case 'P':  // Пауза
          // Извлекаем число после P, если не получилось - оставляем паузу как есть
          priorPause = extractInt(after: 'P', source: code) ?? priorPause;

          break;
      }

      // counter++;
    }

    if (vbPattern.isNotEmpty) {
      _vbDev.vibratePattern(customPattern: vbPattern);
    }
  }
}

