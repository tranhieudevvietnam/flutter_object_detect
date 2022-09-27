import 'dart:io';

import 'package:flutter/material.dart';

import 'image_processor.dart';

class ImageCropView extends StatefulWidget {
  final String pathImage;
  final Rect boundingBox;

  const ImageCropView(
      {Key? key, required this.pathImage, required this.boundingBox})
      : super(key: key);

  @override
  State<ImageCropView> createState() => _ImageCropViewState();
}

class _ImageCropViewState extends State<ImageCropView> {
  File? _imageCrop;

  double _imageWidth = 0.0;
  double _imageHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      imageCrop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image detect crop ")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _imageCrop != null
              ? Image.file(_imageCrop!, fit: BoxFit.contain)
              : const SizedBox(),
        ),
      ),
    );
  }

  void imageCrop() async {
    FileImage(File(widget.pathImage))
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) async {
      _imageHeight = info.image.height.toDouble();
      _imageWidth = info.image.width.toDouble();
      try {
        // double factorX = screen.width;
        // double factorY = _imageHeight / _imageWidth * screen.width;

        // final max = _recognitions.reduce((value, element) =>
        //     (value.confidenceInClass ?? 0) > (element.confidenceInClass ?? 0)
        //         ? value
        //         : element);

        // if (_recognitions
        //     .where(
        //         (element) => element.confidenceInClass == max.confidenceInClass)
        //     .isNotEmpty) {
        File? croppedImage;
        croppedImage = await ImageProcessor.cropSquare(
          widget.pathImage,
          x: widget.boundingBox.left * _imageWidth,
          y: widget.boundingBox.top * _imageHeight,
          w: (widget.boundingBox.right) * _imageWidth,
          h: (widget.boundingBox.bottom) * _imageHeight,
        );

        if (croppedImage != null) {
          _imageCrop = File(croppedImage.path);
          setState(() {});
        }
        // }
      } catch (error) {}
    }));
  }
}
