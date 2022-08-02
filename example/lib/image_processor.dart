import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
      img.Image destImage = img.copyCrop(src, x.round().toInt(),
          y.round().toInt(), w.round().toInt(), h.round().toInt());
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
