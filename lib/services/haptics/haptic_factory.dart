// lib/services/haptics/haptic_factory.dart

import 'package:vibe_echo/services/haptics/haptic_interface.dart';
import 'package:vibe_echo/services/haptics/haptic_simple.dart';
import 'package:vibe_echo/services/haptics/haptic_advanced.dart';

final hapticMode = String.fromEnvironment(
  'HAPTIC_MODE',
  defaultValue: VibeMode.advanced.name,
).toUpperCase();

Future<HapticEngine> createHapticEngine() async {
  if (hapticMode == 'ADVANCED') {
    return HapticAdvanced.create();
  } else {
    return HapticSimple.create();
  }
}