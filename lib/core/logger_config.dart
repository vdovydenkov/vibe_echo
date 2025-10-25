// lib/core/logger_config.dart

import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Класс для вывода через debugPrint
class DebugPrintOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // Выводим в debug console
      debugPrint(line);
    }
  }
}

/// Настраивает собственный логгер
Logger initLogger() {
  return Logger(
    printer: PrettyPrinter(
      // Сколько строк метода (call frames) показывать при обычном логировании
      // (когда нет error/stackTrace).
      methodCount:       1,
      // Сколько методов показывать при логировании ошибки
      // (когда есть stackTrace или уровень error). Обычно больше, чем methodCount,
      // чтобы при ошибке видеть глубже стек. 
      errorMethodCount:  3,
      // Ширина «рамки» и длина разделителей. Если установить маленькое значение — рамка будет короче.
      lineLength:        80,
      // Использовать ANSI-цвета (в терминалах, которые это поддерживают).
      // false — убирает ANSI-коды, полезно для логов в файлы.
      colors:            false,
      // Показывать эмодзи перед сообщением в зависимости от уровня.
      printEmojis:       false,
      // Управляют «упаковкой» сообщения в рамку.
      noBoxingByDefault: true,
      // Включает/форматирует метку времени в выводе. Варианты (в зависим. от версии пакета)
      // none (без времени), onlyTimeAndSinceStart (только время и время с начала приложения), dateAndTime (полная дата+время)...
      dateTimeFormat:    DateTimeFormat.dateAndTime,
    ),

    output: DebugPrintOutput(),
  );
}
