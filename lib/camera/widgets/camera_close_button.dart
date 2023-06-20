import 'package:flutter/material.dart';

///
class CameraCloseButton extends StatelessWidget {
  ///
  const CameraCloseButton({
    Key? key,
  }) : super(key: key);

  ///

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        //     overlays: SystemUiOverlay.values);
        Navigator.of(context).pop();
      },
      child: Container(
        height: 36.0,
        width: 36.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 16.0,
        ),
      ),
    );
  }
}
