// lib/services/commands/clear_handler.dart
part of 'handlers.dart';

/// Обработчик команды CLEAR
/// Очищает экран, возвращая пустую строку и команду перезаписи
CmdResult clearHandler() => CmdResult(
  action: ActionValues.replace,
  text: ''
);