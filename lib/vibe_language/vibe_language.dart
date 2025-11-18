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

import 'package:logger/logger.dart';
import 'package:vibe_echo/core/di.dart';
import 'package:vibe_echo/services/haptics/haptic_interface.dart';
import 'package:vibe_echo/config/configurator.dart';
import 'package:vibe_echo/utils/extractors.dart';

/// Класс для работы с виброкодом.
/// Виброкод - последовательность тегов, транслируемой в вибросигналы
/// Использует синглтон VibeDevice
/// Может выбросить исключение при getDependency
class Vibrocode {
  // --- Будем Вынимать из DI в конструкторе
  // Вибросигнализатор - без него ничего не работает
  late final HapticEngine _vibeDevice;
  // Конфигурация: прежде всего, vbOpt
  late final Config       _cfg;
  // Внешний логгер. Если не передадут (null) - лога не будет.
  late final Logger?      _externalLogger;

  /// В конструкторе вынемаем VibeDevice и Config из DI
  Vibrocode() {
    // Исключение не отлавливается - без вибросигнализатора класс смысла не имеет
    _vibeDevice = getDependency<HapticEngine>();
    _cfg        = getDependency<Config>();

    // А логгер не критичен, если его нет - просто null
    _externalLogger = isRegistered<Logger>() ? getDependency<Logger>() : null;
  }

  /// Транслирует виброкод в паттерны для вибросигнализатора
  /// Возвращает два списка: 
  /// * список пауз и вибросигналов
  /// * список амплитуд
  (List<int>, List<int>) parseToList({
    required String vibroCode
  }) {
    vibroCode = vibroCode.trim();

    if (vibroCode.isEmpty) {
      return ([], []);
    }

    // Разбираем строку по блокам - сепаратор любое кол-во пробелов
    final List<String> codes = vibroCode
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Признак кода: V, P, R и т.д.
    String prefix;
    // Предыдущее значение паузы сначала берем по умолчанию
    int pause = _cfg.vbOpt.internalPause;
    // Длина повторяемой цепочки
    int chainLength = 0;
    // Скорость: коэффициент, на который умножаются длительности
    double speedCoefficient = 1;

    // Список для vibration pattern (паузы и вибрация)
    List<int> vbPattern  = [];

    // Сюда будем заполнять амплитуды для каждой вибрации
    List<int> amplitudes = [];
    // Максимальное значение амплитуды - значение по умолчанию
    int amplitude = 255;

    // Преобразуем набор кодов в список pattern из vibration
    // Список из длительностей пауз и вибраций
    for (var code in codes) {
      prefix = code[0];
      switch (prefix) {
        case 'V':  // Вибрация
          // Извлекаем число после V
          // Длительность вибросигнала в мс
          final int? value = extractInt(after: 'V', source: code);

          // Число не вытащили, уходим
          if (value == null) {
            break;
          }

          // Вставляем текущее значение паузы
          vbPattern.add(pause);
          // И нулевую амплитуду
          amplitudes.add(0);

          // Вставляем вибрацию заданной длительности, умноженную на коэффициент скорости
          vbPattern.add((value * speedCoefficient).round());
          // И текущее значение амплитуды для этой вибрации
          amplitudes.add(amplitude);

          // Увеличиваем размер цепочки для повтора, если потребуется повторить
          chainLength++;
          break;
        case 'A':  // Амплитуда
          // Извлекаем число после A, если не получилось - оставляем амплитуду
          amplitude = extractInt(after: 'A', source: code) ?? amplitude;
        case 'P':  // Пауза
          // Извлекаем число после P, если не получилось - оставляем паузу как есть
          pause = extractInt(after: 'P', source: code) ?? pause;
          // Домножим на коэффициент скорости
          pause = (pause * speedCoefficient).round();

          break;
        case 'R':  // Повтор последнего отрезка
          // Извлекаем число после R
          // Количество повторов последнего отрезка
          final int? cycle = extractInt(after: 'R', source: code);

          // Числа не вытащили или повторять нечего, уходим
          if ((cycle == null) || (chainLength == 0)) {
            break;
          }

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
        case 'S':  // Скорость
          // Извлекаем число после S, если не получилось - сбрасываем в 0
          // Число после S - процент ускорения или замедления
          // S10 — плюс 10 процентов, S-50 — в половину медленнее (50 процентов)
          final coefficient = extractInt(after: 'S', source: code) ?? 0;
          // Проверим диапазон
          if (coefficient < -99 || coefficient > 100) {
            // Логгируем, что задан ошибочный диапазон
            _externalLogger?.d(
              'Speed coefficient ($coefficient) is out of range [-99..100]',
            );
            break;
          }

          // Рассчитываем коэффициент скорости:
          // на что нужно домножить длительность и паузу,
          // чтобы соответствовать установленной скорости
          if (coefficient < 0) {
            // Замедляем скорость:
            // множитель больше единицы, увеличивает длительность вибрации и паузы
            // Значение берем по модулю, чтобы не появился минус в выражении
            speedCoefficient = 1 + coefficient.abs() / 100;
          } else if (coefficient > 0) {
            // Увеличиваем скорость:
            // множитель меньше единицы, сокращает длительность вибрации и паузы
            speedCoefficient = 1 - coefficient / 100;
          } else if (coefficient == 0)  {
            // Скорость приводим к нормальной
            speedCoefficient = 1;
          }

          _externalLogger?.d(
            'speedCoefficient = $speedCoefficient, '
            'coefficient = $coefficient',
          );
          // Обновим значение паузы
          pause = (pause * speedCoefficient).round();
          break;
      }
    }

    return (vbPattern, amplitudes);
  }
  
  /// Транслирует и проигрывает виброкод
  void perform({required String source}) {
    // Разбираем строку кодов в список — паттерны для вибросигнализатора
    final (timings, amplitudes) = parseToList(vibroCode: source);

    // И сразу "проигрываем" на устройстве
    _vibeDevice.vibrateList(
        timingSequenceList: timings,
        amplitudes: amplitudes,
    );
  }
}

