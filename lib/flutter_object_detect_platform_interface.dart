import 'dart:io';

import 'package:flutter_object_detect/models/detected_object.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_object_detect_method_channel.dart';

abstract class FlutterObjectDetectPlatform extends PlatformInterface {
  /// Constructs a FlutterObjectDetectPlatform.
  FlutterObjectDetectPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterObjectDetectPlatform _instance =
      MethodChannelFlutterObjectDetect();

  /// The default instance of [FlutterObjectDetectPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterObjectDetect].
  static FlutterObjectDetectPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterObjectDetectPlatform] when
  /// they register themselves.
  static set instance(FlutterObjectDetectPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> loadModel(String pathModel);

  Future<List<DetectedObject>> detectImage(String pathImage);
 
}
