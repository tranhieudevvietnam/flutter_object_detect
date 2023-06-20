import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// class ImageCropWidget extends StatefulWidget {
//   final String pathImage;
//   final Rect boundingBox;

//   const ImageCropWidget(
//       {Key? key, required this.pathImage, required this.boundingBox})
//       : super(key: key);

//   @override
//   State<ImageCropWidget> createState() => _ImageCropWidgetState();
// }

// class _ImageCropWidgetState extends State<ImageCropWidget> {
//   File? _imageCrop;

//   double _imageWidth = 0.0;
//   double _imageHeight = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       imageCrop();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: _imageCrop != null
//           ? Image.file(_imageCrop!, fit: BoxFit.contain)
//           : LoadingView(),
//     );
//   }

//   void imageCrop() async {
//     FileImage(File(widget.pathImage))
//         .resolve(const ImageConfiguration())
//         .addListener(ImageStreamListener((ImageInfo info, bool _) async {
//       _imageHeight = info.image.height.toDouble();
//       _imageWidth = info.image.width.toDouble();
//       try {
//         // double factorX = screen.width;
//         // double factorY = _imageHeight / _imageWidth * screen.width;

//         // final max = _recognitions.reduce((value, element) =>
//         //     (value.confidenceInClass ?? 0) > (element.confidenceInClass ?? 0)
//         //         ? value
//         //         : element);

//         // if (_recognitions
//         //     .where(
//         //         (element) => element.confidenceInClass == max.confidenceInClass)
//         //     .isNotEmpty) {
//         File? croppedImage;
//         croppedImage = await ImageProcessor.cropSquare(
//           widget.pathImage,
//           x: widget.boundingBox.left * _imageWidth,
//           y: widget.boundingBox.top * _imageHeight,
//           w: (widget.boundingBox.right) * _imageWidth,
//           h: (widget.boundingBox.bottom) * _imageHeight,
//         );

//         if (croppedImage != null) {
//           _imageCrop = File(croppedImage.path);
//           setState(() {});
//         }
//         // }
//       } catch (error) {}
//     }));
//   }
// }

class ImageProcessor {
  static Future<File?> cropSquare(String srcFilePath,
      {required double x,
      required double y,
      required double w,
      required double h,
      bool flip = false}) async {
    var bytes = await File(srcFilePath).readAsBytes();
    img.Image? src = img.decodeImage(bytes);
    if (src != null) {
      // var cropSize = math.min(src.width, src.height);
      // int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
      // int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

      // IMG.Image destImage =
      //     IMG.copyCrop(src, offsetX, offsetY, cropSize, cropSize);
      img.Image destImage = img.copyCrop(src,
          x: x.round().toInt(),
          y: y.round().toInt(),
          width: w.round().toInt(),
          height: h.round().toInt());
      // log("x: $x");
      // log("y: $y");
      // log("w: $w");
      // log("h: $h");
      if (flip) {
        destImage = img.flipVertical(destImage);
      }

      var jpg = img.encodeJpg(destImage);
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      return (await File("$tempPath/image_temp1_${srcFilePath.split("/").last}")
              .create())
          .writeAsBytes(jpg);
    }
    return null;
  }

  static Future<List<int>> resizeImage(File imageFile) async {
    // Read a jpeg image from file.
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    img.Image thumbnail = img.copyResize(image, width: 640, height: 640);
    var byteImage = img.encodePng(thumbnail);
    return byteImage;
  }
}
