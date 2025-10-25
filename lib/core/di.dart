// lib/core/di.dart

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Универсальная функция для регистрации объекта в DI-контейнере
void setupDependency<T extends Object>(T obj) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(() => obj);
  }
}

/// Проверка наличия регистрации объекта определённого типа
bool isRegistered<T extends Object>() => getIt.isRegistered<T>();

/// Получение объекта из DI
T getDependency<T extends Object>() => getIt<T>();
