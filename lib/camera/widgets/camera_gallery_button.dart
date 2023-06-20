import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/cam_controller.dart';
import '../views/camera_builder.dart';

///
class CameraGalleryButton extends StatefulWidget {
  final Function(File?) onResult;

  ///
  const CameraGalleryButton({
    Key? key,
    required this.controller,
    required this.onResult,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  State<CameraGalleryButton> createState() => _CameraGalleryButtonState();
}

class _CameraGalleryButtonState extends State<CameraGalleryButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: widget.controller,
      builder: (value, child) {
        return GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              widget.onResult.call(File(image.path));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(100)),
            width: 54.0,
            height: 54.0,
            child: const Icon(
              Icons.wallpaper,
              color: Colors.white,
            ),
            // child: value.hideCameraGalleryButton
            //     ? const SizedBox()
            //     : GalleryViewField(
            //       onChanged: (entity, _){
            //         //
            //       },
            //     ),
          ),
        );
      },
    );
  }
}
