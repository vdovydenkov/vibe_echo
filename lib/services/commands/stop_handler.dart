// lib/services/commands/stop_handler.dart
part of 'handlers.dart';

/// Обработчик команды STOP
/// Останавливает вибрацию, возвращает OK.
CmdResult stopHandler() {
  try {
    // Пытаемся вынуть синглтон из DI
    final vbDev = getDependency<VibeDevice>();

    vbDev.stop();

    return CmdResult(
        action: ActionValues.ok,
        text: ''
    );
  } catch (e) {
    return CmdResult(
        action: ActionValues.error,
        text: '\nstopHandler\n${e.toString()}'
    );
  }
}