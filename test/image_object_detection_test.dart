import 'package:flutter_test/flutter_test.dart';
import 'package:image_object_detection/image_object_detection.dart';
import 'package:image_object_detection/image_object_detection_platform_interface.dart';
import 'package:image_object_detection/image_object_detection_method_channel.dart';
import 'package:image_object_detection/models/detected_object.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImageObjectDetectionPlatform
    with MockPlatformInterfaceMixin
    implements ImageObjectDetectionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<DetectedObject>> detectImage(String pathImage) {
    // TODO: implement detectImage
    throw UnimplementedError();
  }

  @override
  Future<String?> loadModel(String pathModel) {
    // TODO: implement loadModel
    throw UnimplementedError();
  }
}

void main() {
  final ImageObjectDetectionPlatform initialPlatform =
      ImageObjectDetectionPlatform.instance;

  test('$MethodChannelImageObjectDetection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelImageObjectDetection>());
  });

  test('getPlatformVersion', () async {
    ImageObjectDetection imageObjectDetectionPlugin = ImageObjectDetection();
    MockImageObjectDetectionPlatform fakePlatform =
        MockImageObjectDetectionPlatform();
    ImageObjectDetectionPlatform.instance = fakePlatform;

    expect(await imageObjectDetectionPlugin.getPlatformVersion(), '42');
  });
}
