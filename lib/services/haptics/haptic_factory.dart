// lib/services/haptics/haptic_factory.dart

import 'package:vibe_echo/services/haptics/haptic_interface.dart';
import 'package:vibe_echo/services/haptics/haptic_simple.dart';
import 'package:vibe_echo/services/haptics/haptic_advanced.dart';

const hapticModeRaw = String.fromEnvironment(
  'HAPTIC_MODE',
  defaultValue: 'ADVANCED');

Future<HapticEngine> createHapticEngine() async {
  final hapticMode = hapticModeRaw
      .trim().toUpperCase();

  if (hapticMode == 'ADVANCED') {
    return HapticAdvanced.create();
  } else {
    return HapticSimple.create();
  }
}