// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:flutter/services.dart';
// import 'package:flutter_object_detect/flutter_object_detect.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String _platformVersion = 'Unknown';
//   final _flutterObjectDetectPlugin = FlutterObjectDetect();

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // We also handle the message potentially returning null.
//     try {
//       platformVersion =
//           await _flutterObjectDetectPlugin.getPlatformVersion() ?? 'Unknown platform version';
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Text('Running on: $_platformVersion\n'),
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_object_detect/models/detected_object.dart';
import 'package:flutter_object_detect_example/image_crop_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_object_detect/flutter_object_detect.dart';

import 'image_processor.dart';
import 'object_detector_painter.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<DetectedObject> _recognitions = [];
  File? _image;
  late Size screen;
  final _flutterObjectDetectPlugin = FlutterObjectDetect();

  Offset? position;
  Offset? positionCurrent;
  final GlobalKey _keyRed = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;

    // log("device width: ${MediaQuery.of(context).size.width}");
    // log("device height: ${MediaQuery.of(context).size.height}");

    // stackChildren.add(_image == null
    //     ? const Text('No image selected.')
    //     : Image.file(_image!, fit: BoxFit.cover));

    return Scaffold(
      appBar: AppBar(
        title: const Text('tflite example app'),
      ),
      body: SafeArea(
        // child: Stack(
        //   children: stackChildren,
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("dx: ${position?.dx} -  dy: ${position?.dy}"),
            Expanded(
              child: _image != null
                  ? Center(
                      child: Container(
                        color: Colors.red,
                        child: CustomPaint(
                            key: _keyRed,
                            foregroundPainter: ObjectDetectorPainter(
                                _recognitions,
                                positionCurrentChange: positionCurrent),
                            child: Listener(
                              onPointerMove: (point) {
                                try {
                                  final RenderBox renderBoxRed = _keyRed
                                      .currentContext!
                                      .findRenderObject()! as RenderBox;
                                  final sizeRed = renderBoxRed.size;

                                  final dx = point.position.dx /
                                      screen.width *
                                      sizeRed.width;
                                  final dy = point.position.dy /
                                      screen.height *
                                      sizeRed.height;

                                  if ((dx < sizeRed.width && dx > 0) &&
                                      (dy < sizeRed.height && dy > 0)) {
                                    setState(() {
                                      position = Offset(
                                          point.position.dx, point.position.dy);
                                      positionCurrent = Offset(dx, dy);
                                    });
                                  }
                                } catch (error) {
                                  // TODO
                                }
                              },
                              child: Image.file(
                                _image!,
                                fit: BoxFit.contain,
                              ),
                            )),
                      ),
                    )
                  : const Text('No image selected.'),
            ),
            TextButton(
                onPressed: () async {
                  final path =
                      '${(await getTemporaryDirectory()).path}/${_image!.path.split("/").last}';
                  final file = File(path);
                  file.create(recursive: true);
                  file.writeAsBytes(_image!.readAsBytesSync());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ImageCropView(
                          pathImage: file.path,
                          boundingBox: _recognitions.first.boundingBox)));
                },
                child: const Text("Crop Image"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await predictImagePicker();
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.image),
      ),
    );
  }

  Future predictImagePicker() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    FileImage(File(image.path))
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) async {
      log("xxxxwidth:${info.image.height.toDouble()}");
      log("xxxxheight:${info.image.width.toDouble()}");
      final path =
          '${(await getTemporaryDirectory()).path}/${DateTime.now().toLocal()}';
      await Directory(path).create(recursive: true);
      File file = File("$path/${image.path.split("/").last}");
      await file.create(recursive: true);

      await file
          .writeAsBytes(await ImageProcessor.resizeImage(File(image.path)));

      final result = await _flutterObjectDetectPlugin.detectImage(file.path);
      _recognitions = result;
      positionCurrent = null;
      position = null;
      log("path1: ${image.path}");
      log("path2: ${file.path}");
      setState(() {
        _image = File(image.path);
      });
    }));
  }

  void _initializeDetector() async {
    const path =
        'assets/tensorflow/lite_model_ssd_mobilenet_v1_1_metadata_2.tflite';
    final modelPath = await _getModel(path);
    String? result = await _flutterObjectDetectPlugin.loadModel(modelPath);
    log("init model: $result");
  }

  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    var file = File("$appDocPath/$assetPath");
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.create(recursive: true);
      await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          flush: true);
    }
    return file.path;
  }
}
