// lib/main.dart

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Собственные модули
import 'package:vibe_echo/services/vibe_device.dart';
import 'package:vibe_echo/core/logger_config.dart';
import 'package:vibe_echo/core/di.dart';
import 'package:vibe_echo/config/configurator.dart';
import 'package:vibe_echo/services/local_server/local_server.dart';

const appTitle = 'Vibe Echo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final myLog = initLogger();  
  myLog.i('Starting...');
  setupDependency<Logger>(myLog);

  final vibeDevice = await VibeDevice.create();
  vibeDevice.selfLogger = myLog;
  setupDependency<VibeDevice>(vibeDevice);

  vibeDevice.vibratePreset(preset: VibePreset.startApp);

  final Config cfg = Config.instance;
  setupDependency<Config>(cfg);

  final commands = await startControlPanelServer(
    htmlTemplatePath: cfg.cPanelTemplatePath,
    port:             cfg.cPanelPort,
    extLog:           myLog,
  );

  commands.listen((cmd) {
    myLog.i('Пришло с CPanel: $cmd');
  });

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
  final myLog      = getDependency<Logger>();
  final vibeDevice = getDependency<VibeDevice>();
  
  String _mainText = 'Добро пожаловать';

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
                onPressed: () => _onButtonPressed('Первый', VibePreset.symb1),
                child: const Text('1'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Второй', VibePreset.symb2),
                child: const Text('2'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Третий', VibePreset.symb3),
                child: const Text('3'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Четвёртый', VibePreset.symb4),
                child: const Text('4'),
              ),
              ElevatedButton(
                onPressed: () => _onButtonPressed('Пятый', VibePreset.symb5),
                child: const Text('5'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
