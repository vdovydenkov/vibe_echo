// lib/main.dart

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Собственные модули
import 'package:vibe_echo/services/haptics/haptic_factory.dart';
import 'package:vibe_echo/core/logger_config.dart';
import 'package:vibe_echo/core/di.dart';
import 'package:vibe_echo/config/configurator.dart';
import 'package:vibe_echo/services/haptics/haptic_interface.dart';
import 'package:vibe_echo/services/local_server/local_server.dart';
import 'package:vibe_echo/services/commands/command_dispatcher.dart';

const appTitle = 'Vibe Echo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final myLog = initLogger();  
  myLog.i('Starting...');
  setupDependency<Logger>(myLog);

  final vibeDevice = await createHapticEngine();
  vibeDevice.selfLogger = myLog;
  setupDependency<HapticEngine>(vibeDevice);
  myLog.i('Vibration mode: ${vibeDevice.mode}');

  vibeDevice.vibratePreset(preset: VibePreset.launched);

  final Config cfg = Config.instance;
  setupDependency<Config>(cfg);

  runApp(const VibeEchoApp());
}

class VibeEchoApp extends StatelessWidget {
  const VibeEchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Echo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Состояние главной страницы
class _HomeScreenState extends State<HomeScreen> {
  // Достаём синглтоны: логгер и устройство
  final vibeDevice = getDependency<HapticEngine>();
  final myLog      = getDependency<Logger>();
  final cfg        = getDependency<Config>();
  
  String _mainText = 'ДОБРО ПОЖАЛОВАТЬ';

  late ControlPanelServer _cPanelServer;
  final CmdDispatcher cPanelCommandDispatcher = CmdDispatcher();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        _mainText += '\nРежим вибрации: ${vibeDevice.mode}';
      });
    }
    
    _startServer();
  }

  Future<void> _startServer() async {
    _cPanelServer = await startControlPanelServer(
      htmlTemplatePath: cfg.cPanelTemplatePath,
      port:             cfg.cPanelPort,
      extLog:           myLog,
    );

    if (mounted) {
      setState(() {
        _mainText += '\nПанель управления доступна по адресу:\n${_cPanelServer.address}';
      });
    }

    _cPanelServer.stream.listen((cmd) async {
      myLog.d('From CPanel: $cmd');
      if (mounted) {
        // Выводим текст команды
        setState(() {
          _mainText += '\n$cmd';
        });

        // Отправляем на парсинг и исполнение
        final CmdResult status = await cPanelCommandDispatcher.
            execute(cmd: cmd);
        
        // Будем собирать сюда новый текст основного экрана
        String newMainText = _mainText;

        switch (status.action) {
          case ActionValues.ok:
            // Что-то он там своё сделал, в этом месте действий не требуется
            break;
          case ActionValues.append:
            // Добавляем текст к существующему, через перевод строки
            newMainText += '\n${status.text}';
            break;
          case ActionValues.replace:
            // Заменяем текст на экране новым текстом
            newMainText = status.text;
            break;
          case ActionValues.error:
            // Логгируем ошибку и выводим на экран
            myLog.e(status.text);
            newMainText += 'Ошибка при выполнении команды:\n${status.text}';
        }

        // Если текст изменился - обновляем
        if (newMainText != _mainText) {
          setState(() {
            _mainText = newMainText;
          });
      }
      }
    });
  }

  @override
  void dispose() {
    _cPanelServer.stop();
    super.dispose();
  }

  // Функция для обработки нажатия на кнопку
  void _onButtonPressed(String text, VibePreset preset) {
    // ScaffoldMessenger — стандартный способ показать SnackBar (сообщение)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
    myLog.i('Button pressed with text: $text');
    vibeDevice.vibratePreset(preset: preset);
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold — базовая структура экрана: AppBar, тело и др.
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      // Тело экрана
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // пространство между текстом и кнопками
        crossAxisAlignment: CrossAxisAlignment.center,      // выравниваем по вертикали
        children: [
          // Левая часть — текстовое поле
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // прижимаем к левому краю
                  children: [
                    Text(
                      _mainText,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Правая часть — колонка кнопок
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // по вертикали центр
            crossAxisAlignment: CrossAxisAlignment.end,  // кнопки вправо
            children: [
              ElevatedButton(
                onPressed: () => _onButtonPressed('Первый', VibePreset.test1),
                child: const Text('1'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Второй', VibePreset.test2),
                child: const Text('2'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Третий', VibePreset.test3),
                child: const Text('3'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Четвёртый', VibePreset.test4),
                child: const Text('4'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Пятый', VibePreset.test5),
                child: const Text('5'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
