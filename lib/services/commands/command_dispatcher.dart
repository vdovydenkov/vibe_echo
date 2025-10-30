// lib/services/commands/command_dispatcher.dart

import 'package:vibe_echo/core/di.dart';
import 'package:vibe_echo/config/configurator.dart';
import 'package:logger/logger.dart';
import 'package:vibe_echo/services/commands/handlers.dart';

/// Возможные значение после разбора команды
enum ActionValues {
  append,   // Добавить приложеный текст
  replace,  // Заместить приложенным текстом
  error,    // Текст ошибки в приложенном тексте
  ok,       // Действий не требуется
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
  late final Config  _cfg;
  late final Logger? _log;
  
  CmdDispatcher() {
    // Пробуем вынуть логгер, иначе - null
    try {
      _log = getDependency<Logger>();
    } catch (e) {
      _log = null;
    }

    // Пробуем вынуть конфиг, иначе - значения по умолчанию
    try {
      _cfg = getDependency<Config>();
    } catch (e) {
      _log?.e(e.toString());
      _cfg = Config.instance;
    }
  }

  /// Парсит и выполняет команду.
  /// Возвращает actionValues action и String text.
  Future<CmdResult> execute({
    required String cmd
  }) async {
    // Исходно возвращаем: команда не опознана
    CmdResult r = CmdResult(action: ActionValues.error, text: 'Команда не опознана.');

    // Если команда пустая
    if (cmd.isEmpty) return r;
    
    // Если начинается с префикса виброкода
    if (cmd.startsWith(_cfg.vibroCodePrefix)) {
      // Всё OK, дальнейших действий не требуется
      r.action = ActionValues.ok;
      r.text = '';
      return r;
    }

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