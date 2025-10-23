import 'package:flutter/material.dart'; // Подключаем Flutter UI-библиотеку
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

const appTitle = 'Vibe Echo';

void vibrate(int vibroPreset) {
  switch (vibroPreset) {
    case 1:
      Vibration.vibrate(duration: 1000); // вибрация одну секунду: всегда для теста
      debugPrint('duration: 1000');
      break;
    case 2:
      Vibration.vibrate(duration: 2000, amplitude: 96); // средняя сила вибрации
      debugPrint('duration: 2000, amplitude: 96');
      break;
    case 3:
      Vibration.vibrate(pattern: [200, 300, 200, 300, 200, 300]);
      debugPrint('pattern: [200, 300, 200, 300, 200, 300]');
      break;
    case 4:
      Vibration.vibrate(
        pattern: [200, 400, 200, 600, 200, 800, 200, 1000],
        intensities: [50, 128, 200, 250],
      );
      debugPrint('pattern: [200, 400, 200, 600, 200, 800, 200, 1000],\nintensities: [50, 128, 200, 250]');
      break;
    case 5:
      // Готовые паттерны singleShortBuzz, doubleBuzz, heartbeatVibration, emergencyAlert
      Vibration.vibrate(preset: VibrationPreset.emergencyAlert);
      debugPrint('preset: VibrationPreset.emergencyAlert');
      break;
    default:
      Vibration.vibrate(duration: 5000);
      debugPrint('Default case: duration: 5000');
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
