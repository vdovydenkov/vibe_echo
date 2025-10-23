import 'package:flutter/material.dart';

// Собственные модули
import 'package:vibe_echo/services/vibe_device.dart';

const appTitle = 'Vibe Echo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final vibeDevice = await VibeDevice.create();

  // Запускаем корневой виджет MyApp
  runApp(MyApp(vibeDevice: vibeDevice));
}

// Корневой виджет
class MyApp extends StatelessWidget {
  final VibeDevice vibeDevice;
  
  const MyApp({super.key, required this.vibeDevice});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Echo',
      home: MyHomePage(vibeDevice: vibeDevice),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VibeDevice vibeDevice;

  const MyHomePage({super.key, required this.vibeDevice});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Состояние главной страницы
class _MyHomePageState extends State<MyHomePage> {
  // Функция для обработки нажатия на кнопку
  void _onButtonPressed(String text, int preset) {
    // ScaffoldMessenger — стандартный способ показать SnackBar (сообщение)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
    widget.vibeDevice.vibratePreset(preset: preset);
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
              onPressed: () => _onButtonPressed('Первый', 1),
              child: const Text('1'),
            ),
            ElevatedButton(
              onPressed: () => _onButtonPressed('Второй', 2),
              child: const Text('2'),
            ),
            ElevatedButton(
              onPressed: () => _onButtonPressed('Третий', 3),
              child: const Text('3'),
            ),
            ElevatedButton(
              onPressed: () => _onButtonPressed('Четвёртый', 4),
              child: const Text('4'),
            ),
            ElevatedButton(
              onPressed: () => _onButtonPressed('Пятый', 5),
              child: const Text('5'),
            ),
          ],
        ),
      ),
    );
  }
}
