import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../camera/widgets/camera_close_button.dart';
import '../helpers/image_processor.dart';
import '../helpers/object_detector_painter.dart';
import '../image_object_detection.dart';
import '../models/detected_object.dart';

class ImageObjectDetectView extends StatefulWidget {
  const ImageObjectDetectView({
    Key? key,
    required this.image,
  }) : super(key: key);
  final File image;

  @override
  State<ImageObjectDetectView> createState() => _ImageObjectDetectViewState();
}

class _ImageObjectDetectViewState extends State<ImageObjectDetectView> {
  final GlobalKey _keyRed = GlobalKey();

  late Size screen;
  List<DetectedObject> _recognitions = [];
  final _objectDetectPlugin = ImageObjectDetection();

  final List<File> _images = [];

  @override
  void initState() {
    // _initializeDetector();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FileImage(File(widget.image.path))
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) async {
        log("xxxxwidth:${info.image.width.toDouble()}");
        log("xxxxheight:${info.image.height.toDouble()}");
        final path =
            '${(await getTemporaryDirectory()).path}/${DateTime.now().toLocal()}';
        await Directory(path).create(recursive: true);
        File file = File("$path/${widget.image.path.split("/").last}");
        await file.create(recursive: true);

        await file.writeAsBytes(
            await ImageProcessor.resizeImage(File(widget.image.path)));

        final result = await _objectDetectPlugin.detectImage(file.path);
        _recognitions = result;
        // positionCurrent = null;
        // position = null;
        // log("path1: ${widget.image.path}");
        // log("path2: ${file.path}");
        for (var element in result) {
          File? dataCrop;
          if (Platform.isAndroid == true) {
            dataCrop = await ImageProcessor.cropSquare(widget.image.path,
                x: element.boundingBox.left * info.image.width,
                y: element.boundingBox.top * info.image.height,
                w: (element.boundingBox.right - element.boundingBox.left) *
                    info.image.width,
                h: (element.boundingBox.bottom - element.boundingBox.top) *
                    info.image.height);
          } else {
            dataCrop = await ImageProcessor.cropSquare(widget.image.path,
                x: element.boundingBox.left * info.image.width,
                y: element.boundingBox.top * info.image.height,
                w: (element.boundingBox.right) * info.image.width,
                h: (element.boundingBox.bottom) * info.image.height);
          }
          if (dataCrop != null) {
            log("label: ${element.labels.first.text}");
            log("111: ${(element.boundingBox.right - element.boundingBox.left) * info.image.width}");
            log("222: ${(element.boundingBox.bottom - element.boundingBox.top) * info.image.height}");
            final path =
                '${(await getTemporaryDirectory()).path}/${DateTime.now().toLocal()}';
            await Directory(path).create(recursive: true);
            File file = File("$path/${widget.image.path.split("/").last}");
            await file.create(recursive: true);
            await file.writeAsBytes(await dataCrop.readAsBytes());

            _images.add(file);
            // await file.writeAsBytes(await dataCrop.readAsBytes());
            // _image = File(file.path);
          }
        }
        setState(() {});
      }));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black45,
      body: SafeArea(
        child: Stack(
          // fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: ImageCustomPaint(
                  keyRed: _keyRed,
                  recognitions: _recognitions,
                  screen: screen,
                  widget: widget),
            ),
            DraggableScrollableSheet(
              minChildSize: .2,
              maxChildSize: .5,
              initialChildSize: .2,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                      _images.length,
                      (index) => Container(
                        height: 80,
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _images[index],
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ),
                );
              },
            ),
            const Positioned(
              left: 8,
              top: 30,
              child: CameraCloseButton(),
            ),
          ],
        ),
      ),
    );
  }

  // void _initializeDetector() async {
  //   const path =
  //       'assets/tensorflow/lite_model_ssd_mobilenet_v1_1_metadata_2.tflite';
  //   final modelPath = await _getModel(path);
  //   String? result = await _objectDetectPlugin.loadModel(modelPath);
  //   log("init model: $result");
  // }

  // Future<String> _getModel(String assetPath) async {
  //   // if (Platform.isAndroid) {
  //   //   return 'flutter_assets/$assetPath';
  //   // }

  //   Directory appDocDir = await getTemporaryDirectory();
  //   String appDocPath = appDocDir.path;

  //   var file = File("$appDocPath/$assetPath");
  //   if (!await file.exists()) {
  //     try {
  //       final byteData = await rootBundle.load(assetPath);
  //       await file.create(recursive: true);
  //       await file.writeAsBytes(
  //           byteData.buffer
  //               .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  //           flush: true);
  //     } catch (error) {
  //       rethrow;
  //     }
  //   }
  //   return file.path;
  // }
}

class ImageCustomPaint extends StatefulWidget {
  const ImageCustomPaint({
    Key? key,
    required GlobalKey<State<StatefulWidget>> keyRed,
    required List<DetectedObject> recognitions,
    required this.widget,
    required this.screen,
  })  : _keyRed = keyRed,
        _recognitions = recognitions,
        super(key: key);
  final GlobalKey<State<StatefulWidget>> _keyRed;

  final List<DetectedObject> _recognitions;
  final ImageObjectDetectView widget;
  final Size screen;

  @override
  State<ImageCustomPaint> createState() => _ImageCustomPaintState();
}

class _ImageCustomPaintState extends State<ImageCustomPaint> {
  Offset? position;
  Offset? positionCurrent;

  @override
  Widget build(BuildContext context) {
    // log("size.width: ${MediaQuery.of(context).size.width}");

    // log("size.height: ${MediaQuery.of(context).size.height}");
    return Column(
      children: [
        CustomPaint(
          key: widget._keyRed,
          foregroundPainter: ObjectDetectorPainter(widget._recognitions,
              positionCurrentChange: positionCurrent),
          child: Listener(
            onPointerMove: (point) {
              // try {
              //   final RenderBox renderBoxRed = widget._keyRed.currentContext!
              //       .findRenderObject()! as RenderBox;
              //   final sizeRed = renderBoxRed.size;
              //   // log("point: ${point.position.dy}/ ${widget.screen.height}");

              //   final dx =
              //       point.position.dx / widget.screen.width * sizeRed.width;
              //   final dy =
              //       (point.position.dy) / widget.screen.height * sizeRed.height;

              //   if ((dx < sizeRed.width && dx > 0) &&
              //       (dy < sizeRed.height && dy > 0)) {
              //     setState(() {
              //       position = Offset(point.position.dx, point.position.dy);
              //       positionCurrent = Offset(dx, dy);
              //     });
              //   }
              // } catch (error) {
              //   rethrow;
              // }
            },
            child: Image.file(
              widget.widget.image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.decoration,
    this.size,
    this.strokeWidth,
    this.value,
  });

  final BoxDecoration? decoration;
  final double? size;
  final double? strokeWidth;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 35.0,
      height: size ?? 35.0,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 1.5,
          color: Colors.red,
          value: value,
        ),
      ),
    );
  }
}
