import 'package:flutter/material.dart';

class DurationUtil {
  static String? getDurationIntoString(TimeOfDay? duration) {
    if (duration != null) {
      return '${duration!.hour.toString().padLeft(2, '0')}:${duration.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }
}
