// lib/main.dart

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Собственные модули
import 'package:vibe_echo/services/vibe_device.dart';
import 'package:vibe_echo/core/logger_config.dart';
import 'package:vibe_echo/core/di.dart';

const appTitle = 'Vibe Echo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final myLog = initLogger();  
  myLog.i('Starting...');
  setupDependency<Logger>(myLog);

  final vibeDevice = await VibeDevice.create();
  setupDependency<VibeDevice>(vibeDevice);

  // Запускаем корневой виджет MyApp
  runApp(MyApp());
}

// Корневой виджет
class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Echo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Состояние главной страницы
class _MyHomePageState extends State<MyHomePage> {
  // Функция для обработки нажатия на кнопку
  void _onButtonPressed(String text, VibePreset preset) {
    final vibe = getDependency<VibeDevice>();
    // ScaffoldMessenger — стандартный способ показать SnackBar (сообщение)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
    vibe.vibratePreset(preset: preset);
    // widget.vibeDevice.vibratePreset(preset: preset);
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold — базовая структура экрана: AppBar, тело и др.
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      // Тело экрана
      body: Center(
        // Column — вертикальное расположение кнопок
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
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
      ),
    );
  }
}
