import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_object_detection/image_object_detection_method_channel.dart';

void main() {
  MethodChannelImageObjectDetection platform = MethodChannelImageObjectDetection();
  const MethodChannel channel = MethodChannel('image_object_detection');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
