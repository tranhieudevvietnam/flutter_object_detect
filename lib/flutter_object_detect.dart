import 'dart:io';

import 'package:flutter_object_detect/models/detected_object.dart';

import 'flutter_object_detect_platform_interface.dart';

class FlutterObjectDetect {
  Future<String?> getPlatformVersion() {
    return FlutterObjectDetectPlatform.instance.getPlatformVersion();
  }

  Future<String?> loadModel(String pathModel) {
    return FlutterObjectDetectPlatform.instance.loadModel(pathModel);
  }

  Future<List<DetectedObject>> detectImage(String pathImage) {
    return FlutterObjectDetectPlatform.instance.detectImage(pathImage);
  }
}
