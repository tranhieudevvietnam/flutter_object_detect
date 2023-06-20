import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_object_detection/camera/views/raw_camera_view.dart';

import '../controllers/cam_controller.dart';
import '../controllers/cam_controller_provider.dart';
import '../controllers/controller_notifier.dart';
import 'camera_builder.dart';
import 'camera_overlay.dart';

class CameraImageDetectionView extends StatefulWidget {
  final Function(File? file) onSubmit;
  const CameraImageDetectionView({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<CameraImageDetectionView> createState() =>
      _CameraImageDetectionViewState();
}

class _CameraImageDetectionViewState extends State<CameraImageDetectionView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final ControllerNotifier _controllerNotifier;

  late final CamController _camController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _controllerNotifier = ControllerNotifier();
    _camController = CamController(
        controllerNotifier: _controllerNotifier,
        context: context,
        saveImage: true,
        onSubmit: (file) {
          log("file selected: ${file?.path}");
          widget.onSubmit.call(file);
        });
    _hideSB();
    _camController.createCamera();

    super.initState();
  }

  ///
  void _hideSB() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  ///
  // void _showSB() {
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //       overlays: SystemUiOverlay.values);
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _controllerNotifier.controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      // _showSB();
      _controllerNotifier.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // _hideSB();
      _camController.createCamera();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    SystemChrome.restoreSystemUIOverlays();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    WidgetsBinding.instance.removeObserver(this);
    _controllerNotifier.dispose();
    _camController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    _hideSB();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   children: [
    //     Container(
    //         color: Colors.red,
    //         height: MediaQuery.of(context).size.height,
    //         width: MediaQuery.of(context).size.width),
    //     // Camera control overlay
    //     CameraOverlay(
    //       controller: _camController,
    //     ),

    //     // //
    //   ],
    // );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<ControllerValue>(
          valueListenable: _controllerNotifier,
          builder: (context, value, child) {
            if (_controllerNotifier.initialized) {
              return child!;
            }
            return const SizedBox();
          },
          child: CamControllerProvider(
            action: _camController,
            child: Stack(
              children: [
                // Camera type specific view
                CameraBuilder(
                  controller: _camController,
                  builder: (value, child) {
                    // if (value.cameraType == CameraType.text) {
                    //   return Playground(controller: _playgroundController);
                    // }
                    return RawCameraView(action: _camController);
                  },
                ),

                // Camera control overlay
                CameraOverlay(
                  controller: _camController,
                ),

                // //
              ],
            ),
          ),
        ),
      ),
    );
  }
}
