import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

const failSafeHtmlTemplate = '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Vibe Echo — Control panel</title>
  </head>

  <body>
    <form action="http://{{HOST}}:{{PORT}}/execute" method="post">
      <input name="command">
      <button>Send</button>
    </form>
  </body>
</html>
''';

/// ControlPanelServer
/// Содержит поток команд stream,
/// Метод stop() для остановки сервера и закрытия контроллера,
/// Свойство host с адресом к Панели управления
class ControlPanelServer {
  final Stream<String> stream;
  final String address;

  final HttpServer _server;
  final StreamController<String> _controller;

  ControlPanelServer._(
    this._server,
    this._controller,
    this.address,
  ) : stream = _controller.stream;

  Future<void> stop() async {
    await _server.close(force: true);
    await _controller.close();
  }
} 

/// Запускает локальный HTTP-сервер панели управления Vibe Echo.
/// Возвращает `Stream<String>` с командами, приходящими из формы.
Future<ControlPanelServer> startControlPanelServer({
  String  htmlTemplatePath = '',
  int     port             = 8080,
  Logger? extLog,
}) async {
  // Читаем HTML-шаблон
  String htmlTemplate;
  try {
    htmlTemplate = await rootBundle.loadString(htmlTemplatePath);
  } catch (e) {
    htmlTemplate = failSafeHtmlTemplate;
    extLog?.e('Loading html-template error: $e\nUse a failsafe template.');
  }

  // Сюда собираем лог
  String logCollector = 'htmlTemplatePath $htmlTemplatePath\n';

  // Берём адрес
  final host = InternetAddress.anyIPv4;
  logCollector += 'host: $host\n';

  logCollector += 'Raw html template length: {$htmlTemplate.length}\n';

  final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
  logCollector += 'interfaces: $interfaces\n';
  
  final localIp = interfaces
          .expand((i) => i.addresses)
          .map((a) => a.address)
          .firstWhere((a) => !a.startsWith('127.'), orElse: () => '127.0.0.1');
  logCollector += 'localIp: $localIp\n';

  // Формируем страницу с подстановкой адреса и порта
  final html = htmlTemplate
      .replaceAll('{{HOST}}', localIp)
      .replaceAll('{{PORT}}', port.toString());
  logCollector += 'html length: ${html.length}\n';
  
  // Собрали лог, выводим, если передали логгер
  extLog?.d(logCollector);
  
  // Контроллер для команд
  final controller = StreamController<String>.broadcast();

  // Запускаем сервер
  final server = await HttpServer.bind(host, port);

  final address = 'http://$localIp:$port';
  debugPrint('Vibe Echo control panel running on $address');

  // Обработка запросов
  server.listen((HttpRequest req) async {
    try {
      if (req.method == 'GET') {
        // Отдаём страницу
        req.response
          ..headers.contentType = ContentType.html
          ..write(html);
      } else if (req.method == 'POST' && req.uri.path == '/execute') {
        // Может прийти в json или x-www-form-urlencoded
        final contentType = req.headers.contentType?.mimeType;
        final body = await utf8.decoder.bind(req).join();
        late String command;

        if (contentType == 'application/json') {
          final data = json.decode(body);
          command = data['command'] ?? '';
        } else if (contentType == 'application/x-www-form-urlencoded') {
          final data = Uri.splitQueryString(body);
          command = data['command'] ?? '';
        } else {
          // неизвестный формат — вернуть 415 или 400
        }

        // Добавляем команду в поток
        if (command.isNotEmpty) controller.add(command);

        // Возвращаем подтверждение
        req.response
          ..headers.contentType = ContentType.text
          ..write(command);
      } else {
        req.response.statusCode = HttpStatus.notFound;
      }
    } catch (e, st) {
      req.response.statusCode = HttpStatus.internalServerError;
      req.response.write('Error: $e\n$st');
    } finally {
      await req.response.close();
    }
  });

  return ControlPanelServer._(server, controller, address);
}
