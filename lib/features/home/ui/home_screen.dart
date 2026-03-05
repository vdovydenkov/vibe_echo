// lib/features/home/ui/home_screen.dart

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:vibe_echo/config/configurator.dart';
import 'package:vibe_echo/config/constants.dart';
import 'package:vibe_echo/features/vibe_translator/haptics/haptic_interface.dart';
import 'package:vibe_echo/features/local_server/local_server.dart';
import 'package:vibe_echo/features/local_server/command_handlers/command_dispatcher.dart';

class HomeScreen extends StatefulWidget {
  final Logger logger;
  final HapticEngine vibeDevice;
  final Config cfg;

  const HomeScreen({
    super.key,
    required this.logger,
    required this.vibeDevice,
    required this.cfg,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Состояние главной страницы
class _HomeScreenState extends State<HomeScreen> {
  late final Logger logger;
  late final HapticEngine vibeDevice;
  late final Config cfg;
  
  String _mainText = 'ДОБРО ПОЖАЛОВАТЬ';

  late ControlPanelServer _cPanelServer;
  final CmdDispatcher cPanelCommandDispatcher = CmdDispatcher();

  @override
  void initState() {
    super.initState();

    logger = widget.logger;
    vibeDevice = widget.vibeDevice;
    cfg = widget.cfg;

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
      extLog      :     logger,
    );

    if (mounted) {
      setState(() {
        _mainText += '\nПанель управления доступна по адресу:\n${_cPanelServer.address}';
      });
    }

    _cPanelServer.stream.listen((cmd) async {
      logger.d('From CPanel: $cmd');
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
            logger.e(status.text);
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
    logger.i('Button pressed with text: $text');
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
        // пространство между текстом и кнопками
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // выравниваем по вертикали
        crossAxisAlignment: CrossAxisAlignment.center,
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
