// lib/services/commands/command_dispatcher.dart

import 'package:vibe_echo/services/commands/handlers.dart';

/// Возможные значение после разбора команды
enum ActionValues {
  append,
  replace,
  error,
}

class CmdResult {
  ActionValues action;
  String       text;

  CmdResult({
    required this.action,
    required this.text
  });
}

/// Диспетчер (разборщик) команд
class CmdDispatcher {
  CmdDispatcher._();

  /// Парсит и выполняет команду.
  /// Возвращает actionValues action и String text.
  static Future<CmdResult> execute({
    required String cmd
  }) async {
    CmdResult r = CmdResult(action: ActionValues.error, text: 'Команда не опознана.');

    if (cmd.isEmpty) return r;
    
    cmd = cmd.trim().toUpperCase();
    switch (cmd) {
      case 'CHECK':
        r = checkHandler();
        break;
      case 'CLEAR':
        r = clearHandler();
        break;
    }

    return r;
  }
}