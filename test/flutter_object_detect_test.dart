// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_object_detect/flutter_object_detect.dart';
// import 'package:flutter_object_detect/flutter_object_detect_platform_interface.dart';
// import 'package:flutter_object_detect/flutter_object_detect_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterObjectDetectPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterObjectDetectPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterObjectDetectPlatform initialPlatform =
//       FlutterObjectDetectPlatform.instance;

//   test('$MethodChannelFlutterObjectDetect is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterObjectDetect>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterObjectDetect flutterObjectDetectPlugin = FlutterObjectDetect();
//     MockFlutterObjectDetectPlatform fakePlatform =
//         MockFlutterObjectDetectPlatform();
//     FlutterObjectDetectPlatform.instance = fakePlatform;

//     expect(await flutterObjectDetectPlugin.getPlatformVersion(), '42');
//   });
// }
