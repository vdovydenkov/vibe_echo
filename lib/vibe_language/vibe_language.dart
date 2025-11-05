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

  /// Транслирует виброкод в паттерны для вибросигнализатора
  /// Возвращает List со списком пауз и вибросигналов
  List<int> parseToPattern({required String vibroCode}) {
    vibroCode = vibroCode.trim();

    if (vibroCode.isEmpty) return [];

    // Разбираем строку по блокам - сепаратор любое кол-во пробелов
    final List<String> codes = vibroCode
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Признак кода: V, P, R и т.д.
    String prefix;
    // Предыдущее значение паузы сначала берем по умолчанию
    int priorPause = _cfg.vbOpt.internalPause;
    // Длина повторяемой цепочки
    int chainLength = 0;

    // Список для vibration pattern
    List<int> vbPattern = [];

    // Преобразуем набор кодов в список pattern из vibration
    // Список из длительностей пауз и вибраций
    for (var code in codes) {
      prefix = code[0];
      switch (prefix) {
        case 'V':  // Вибрация
          // Извлекаем число после V
          // Длительность вибросигнала в мс
          final int? value = extractInt(after: 'V', source: code);

          // Числа не вытащили, уходим
          if (value == null) break;

          // Вставляем текущее значение паузы
          vbPattern.add(priorPause);
          // Вставляем вибрацию заданной длительности
          vbPattern.add(value);
          // Увеличиваем размер цепочки для повтора, если потребуется повторить
          chainLength++;
          break;
        case 'P':  // Пауза
          // Извлекаем число после P, если не получилось - оставляем паузу как есть
          priorPause = extractInt(after: 'P', source: code) ?? priorPause;

          break;
        case 'R':  // Повтор последнего отрезка
          // Извлекаем число после R
          // Количество повторов последнего отрезка
          final int? cycle = extractInt(after: 'R', source: code);

          // Числа не вытащили или повторять нечего, уходим
          if ((cycle == null) || (chainLength == 0))
            break;

          if (2 * chainLength > vbPattern.length) {
            // Почему-то размер цепочки оказался больше списка
            // Повод для логгирования
            chainLength = 0;
            break;
          }

          // Повторяем последний отрезок заданное количество раз
          for (var i = 1; i < cycle; i++) {
            // Извлекаем из списка последние 2 * chainLength элементов
            // И снова добавляем к списку.
            // (два размера, потому что пауза + вибрация)
            vbPattern.addAll(
              vbPattern.sublist(
                vbPattern.length - (2 * chainLength)
            ));
          }
          // Обнуляем размер повторяемой цепочки
          chainLength = 0;
          break;
      }
    }

    return vbPattern;
  }
  
  /// Транслирует и проигрывает виброкод
  void perform({required String source}) {
    // Разбираем строку кодов в список — паттерны для вибросигнализатора
    // И сразу "проигрываем" на устройстве
    _vbDev.vibratePattern(
      customPattern: parseToPattern(
      vibroCode: source));
  }
}

