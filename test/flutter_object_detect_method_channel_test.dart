import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_object_detect/flutter_object_detect_method_channel.dart';

void main() {
  MethodChannelFlutterObjectDetect platform = MethodChannelFlutterObjectDetect();
  const MethodChannel channel = MethodChannel('flutter_object_detect');

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
