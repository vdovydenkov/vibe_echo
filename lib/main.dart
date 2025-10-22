import 'package:flutter/material.dart'; // Подключаем Flutter UI-библиотеку
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

const appTitle = 'Vibe Echo';

void vibrate(int vibroPreset) {
  switch (vibroPreset) {
    case 1:
      Vibration.vibrate(duration: 500); // вибрация 0.5 секунды
      break;
    case 2:
      Vibration.vibrate(duration: 1000, amplitude: 128); // средняя сила вибрации
      break;
    case 3:
      Vibration.vibrate(pattern: [300, 400, 300, 600]);
      break;
    case 4:
      Vibration.vibrate(
        pattern: [200, 400, 200, 600, 200, 800],
        intensities: [50, 128, 200],
      );
      break;
    case 5:
      // Готовые паттерны singleShortBuzz, doubleBuzz, heartbeatVibration, emergencyAlert
      Vibration.vibrate(preset: VibrationPreset.doubleBuzz);
      break;
    default:
      Vibration.vibrate(duration: 2000);
  }
}

// Точка входа в приложение
void main() {
  runApp(const MyApp()); // Запускаем корневой виджет MyApp
}

// Корневой виджет
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Конструктор с ключом (стандартная практика)

  @override
  Widget build(BuildContext context) {
    // MaterialApp — обёртка, которая задаёт тему и навигацию
    return MaterialApp(
      title: 'Vibe Echo',
      home: const MyHomePage(), // Главная страница приложения
    );
  }
}

// Главный экран — StatefulWidget (так как мы будем показывать SnackBar)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Состояние главной страницы
class _MyHomePageState extends State<MyHomePage> {
  // Функция для обработки нажатия на кнопку
  void _onButtonPressed(String text, int preset) {
    // ScaffoldMessenger — стандартный способ показать SnackBar (сообщение)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)), // Показываем текст
    );
    vibrate(preset);
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
