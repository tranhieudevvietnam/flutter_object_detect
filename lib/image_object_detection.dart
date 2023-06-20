import 'image_object_detection_platform_interface.dart';
import 'models/detected_object.dart';

class ImageObjectDetection {
  Future<String?> getPlatformVersion() {
    return ImageObjectDetectionPlatform.instance.getPlatformVersion();
  }

  Future<String?> loadModel(String pathModel) {
    return ImageObjectDetectionPlatform.instance.loadModel(pathModel);
  }

  Future<List<DetectedObject>> detectImage(String pathImage) {
    return ImageObjectDetectionPlatform.instance.detectImage(pathImage);
  }
}
