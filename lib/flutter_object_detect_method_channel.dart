import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_object_detect/models/detected_object.dart';

import 'flutter_object_detect_platform_interface.dart';

/// An implementation of [FlutterObjectDetectPlatform] that uses method channels.
class MethodChannelFlutterObjectDetect extends FlutterObjectDetectPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_object_detect');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<DetectedObject>> detectImage(String pathImage) async {
    try {
      final result = await methodChannel.invokeMethod<dynamic>(
          'detect_image', <String, dynamic>{"pathFile": pathImage});

      log("detect_image -> ${jsonEncode(result)}");
      final dataTemp = jsonDecode(jsonEncode(result));
      List<DetectedObject> listData = [];
      try {
        listData = List.from(
            (dataTemp as List).map((e) => DetectedObject.fromJson(e)));
      } catch (error) {
        listData = List.from((dataTemp["results"] as List)
            .map((e) => DetectedObject.fromJson(e)));
      }
      return listData;
    } catch (error) {
      return [];
    }
  }

  @override
  Future<String?> loadModel(String pathModel) async {
    final result = await methodChannel.invokeMethod<dynamic>(
        'load_model', <String, dynamic>{"pathModel": pathModel});

    return result;
  }
}
