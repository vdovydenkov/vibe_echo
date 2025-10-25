// lib/core/logger_config.dart

import 'package:logger/logger.dart';

/// Настраивает собственный логгер
Logger initLogger() {
  return Logger(
    printer: PrettyPrinter(
      methodCount:      1,
      errorMethodCount: 3,
      lineLength:       80,
      colors:           true,
      printEmojis:      false,
      dateTimeFormat:   DateTimeFormat.dateAndTime,
    ),
  );
}
