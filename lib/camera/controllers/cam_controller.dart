import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'controller_notifier.dart';
import '../exposure.dart';
import '../ui_handler.dart';
import '../zoom.dart';
import 'package:path/path.dart' as path;

class CamController extends ValueNotifier<ActionValue> {
  CamController({
    required ControllerNotifier controllerNotifier,
    required BuildContext context,
    required this.onSubmit,
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
    this.saveImage = true,
  })  : _controllerNotifier = controllerNotifier,
        _uiHandler = UIHandler(context),
        zoom = Zoom(controllerNotifier),
        exposure = Exposure(controllerNotifier, UIHandler(context)),
        super(ActionValue(
          resolutionPreset: resolutionPreset ?? ResolutionPreset.max,
          imageFormatGroup: imageFormatGroup ?? ImageFormatGroup.jpeg,
        ));

  ///return data
  final Function(File?) onSubmit;

  ///
  final ControllerNotifier _controllerNotifier;

  ///
  final bool saveImage;

  ///
  final Exposure exposure;

  ///
  final Zoom zoom;

  ///
  final UIHandler _uiHandler;

  /// Call this only when [initialized] is true
  CameraController get controller => _controllerNotifier.value.controller!;

  /// Create new camera
  Future<CameraController?> createCamera({
    CameraDescription? cameraDescription,
  }) async {
    var description = cameraDescription ?? value.cameraDescription;
    var cameras = value.cameras;

    // Fetch camera descriptions is description is not available
    if (description == null) {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        description = cameras[0];
      } else {
        description = const CameraDescription(
          name: 'Simulator',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );
      }
    }

    // create camera controller
    final controller = CameraController(
      description,
      value.resolutionPreset,
      imageFormatGroup: value.imageFormatGroup,
    );

    // listen controller
    controller.addListener(() {
      if (controller.value.hasError) {
        final error = 'Camera error ${controller.value.errorDescription}';
        _controllerNotifier.value =
            _controllerNotifier.value.copyWith(error: error);
      }
    });

    try {
      await controller.initialize();
      _controllerNotifier.value = ControllerValue(
        controller: controller,
        isReady: true,
      );
      value = value.copyWith(
        cameraDescription: description,
        cameras: cameras,
      );

      if (controller.description.lensDirection == CameraLensDirection.back) {
        // ignore: unawaited_futures
        controller.setFlashMode(value.flashMode);
      }
      // ignore: unawaited_futures
      Future.wait([
        controller.getMinExposureOffset().then(exposure.setMinExposure),
        controller.getMaxExposureOffset().then(exposure.setMaxExposure),
        controller.getMaxZoomLevel().then(zoom.setMaxZoom),
        controller.getMinZoomLevel().then(zoom.setMinZoom),
      ]);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
    } catch (e) {
      _uiHandler.showSnackBar(e.toString());
    }
    return null;
  }

  /// Take picture
  takePicture() async {
    // if (!initialized) {
    //   _uiHandler.showSnackBar("Couldn't find the camera!");
    //   return null;
    // }

    if (value.isTakingPicture) {
      _uiHandler.showSnackBar('Capturing is currently running..');
      return null;
    }

    try {
      // Update state
      value = value.copyWith(isTakingPicture: true);

      final xFile = await controller.takePicture();
      final file = File(xFile.path);
      final data = await file.readAsBytes();
      final entity = saveImage
          ? await PhotoManager.editor.saveImage(
              data,
              title: path.basename(file.path),
            )
          : AssetEntity(
              id: path.basename(file.path),
              typeInt: 1,
              width: 100,
              height: 100,
            );

      // if (file.existsSync()) {
      //   file.deleteSync();
      // }

      // Update state
      value = value.copyWith(isTakingPicture: false);

      if (entity != null) {
        // final likkEntity = LikkEntity(entity: entity, bytes: data);
        onSubmit.call(file);
        // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        //     overlays: SystemUiOverlay.values);
        // _uiHandler.pop<LikkEntity>(likkEntity);
        // return likkEntity;
        // return file;
      } else {
        _uiHandler.showSnackBar('Something went wrong! Please try again');
        value = value.copyWith(isTakingPicture: false);
        // return null;
      }
    } on CameraException catch (e) {
      _uiHandler.showSnackBar('Exception occured while capturing picture : $e');
      value = value.copyWith(isTakingPicture: false);
      // return null;
    } catch (e) {
      _uiHandler.showSnackBar('Exception occured while capturing picture : $e');
      // return null;
    }
  }
}

class ActionValue {
  ActionValue({
    required this.resolutionPreset,
    required this.imageFormatGroup,
    this.cameraDescription,
    this.cameras = const [],
    this.flashMode = FlashMode.off,
    this.isTakingPicture = false,
  });

  final bool isTakingPicture;

  ///
  final CameraDescription? cameraDescription;

  ///
  final List<CameraDescription> cameras;

  ///
  final ResolutionPreset resolutionPreset;

  ///
  final ImageFormatGroup imageFormatGroup;

  final FlashMode flashMode;

  ActionValue copyWith(
      {CameraDescription? cameraDescription,
      List<CameraDescription>? cameras,
      FlashMode? flashMode,
      bool? isTakingPicture}) {
    return ActionValue(
        resolutionPreset: resolutionPreset,
        imageFormatGroup: imageFormatGroup,
        cameraDescription: cameraDescription ?? this.cameraDescription,
        cameras: cameras ?? this.cameras,
        isTakingPicture: isTakingPicture ?? this.isTakingPicture,
        flashMode: flashMode ?? this.flashMode);
  }
}
