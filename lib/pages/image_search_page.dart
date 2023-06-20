import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_object_detection/camera/views/camera_image_detection_view.dart';
import 'package:image_object_detection/image_object_detection.dart';
import 'package:path_provider/path_provider.dart';

import 'image_object_detact_page.dart';

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({Key? key}) : super(key: key);

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  @override
  void initState() {
    super.initState();

    _initializeDetector();
  }

  void _initializeDetector() async {
    const path =
        'packages/image_object_detection/lib/assets/tensorflow/lite_model_ssd_mobilenet_v1_1_metadata_2.tflite';
    final modelPath = await _getModel(path);
    String? result = await ImageObjectDetection().loadModel(modelPath);
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
      try {
        final byteData = await rootBundle.load(assetPath);
        await file.create(recursive: true);
        await file.writeAsBytes(
            byteData.buffer
                .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
            flush: true);
      } catch (error) {
        rethrow;
      }
    }
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraImageDetectionView(
        onSubmit: (file) {
          if (file != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => ImageObjectDetectView(image: file)));
            setState(() {});
          }
        },
      ),
    );
  }
}
