import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'image_object_detection_method_channel.dart';
import 'models/detected_object.dart';

abstract class ImageObjectDetectionPlatform extends PlatformInterface {
  /// Constructs a ImageObjectDetectionPlatform.
  ImageObjectDetectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImageObjectDetectionPlatform _instance = MethodChannelImageObjectDetection();

  /// The default instance of [ImageObjectDetectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelImageObjectDetection].
  static ImageObjectDetectionPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImageObjectDetectionPlatform] when
  /// they register themselves.
  static set instance(ImageObjectDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

   Future<String?> loadModel(String pathModel);

  Future<List<DetectedObject>> detectImage(String pathImage);

}
