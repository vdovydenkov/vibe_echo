// lib/services/commands/check_handler.dart
part of 'handlers.dart';

/// Обработчик команды CHECK
/// Возвращает информацию о статусе вибромотора (VibeDevice.statusText)
CmdResult checkHandler() {
  try {
    // Достаем singleton: класс управления виброустройством
    final vbDev = getDependency<VibeDevice>();

    return CmdResult(
      action: ActionValues.append,
      text:   vbDev.statusText(),
    );
  } catch (e) {
    return CmdResult(
      action: ActionValues.error,
      // Название модуля и текст ошибки
      text:   'checkHandler\n${e.toString()}',
    );
  }
}
