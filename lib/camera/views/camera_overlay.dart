import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_object_detection/camera/controllers/cam_controller.dart';
import 'package:image_object_detection/camera/widgets/camera_close_button.dart';
import 'package:image_object_detection/camera/widgets/camera_gallery_button.dart';

import '../widgets/camera_shutter_button.dart';

///
const _top = 30.0;

///
class CameraOverlay extends StatelessWidget {
  ///
  const CameraOverlay({
    Key? key,
    // required this.videoDuration,
    required this.controller,
    // required this.playgroundCntroller,
  }) : super(key: key);

  ///
  // final Duration videoDuration;

  ///
  final CamController controller;

  ///

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // // preview, input type page view and camera
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: CameraFooter(controller: controller),
          // ),

          // Close button
          const Positioned(
            left: 8,
            top: _top,
            child: CameraCloseButton(),
          ),

          // // Flash Light
          // Positioned(
          //   right: 8,
          //   top: _top,
          //   child: CameraFlashButton(controller: controller),
          // ),

          // Shutter view
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: CameraShutterButton(
              // videoDuration: videoDuration,
              controller: controller,
            ),
          ),
          // Gallery Button
          Positioned(
            left: 20,
            bottom: 64,
            child: CameraGalleryButton(
              controller: controller,
              onResult: (File? file) {
                controller.onSubmit.call(file);
              },
            ),
          ),

          //
        ],
      ),
    );
  }
}
