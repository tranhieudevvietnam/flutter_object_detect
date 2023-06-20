// import 'dart:ui';
// import 'dart:ui' as ui;

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/detected_object.dart';

class ObjectDetectorPainter extends CustomPainter {
  final List<DetectedObject> listObject;
  final Offset? positionCurrentChange;

  ObjectDetectorPainter(
    this.listObject, {
    this.positionCurrentChange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    // final Paint background = Paint()..color = const Color(0x99000000);
    // log("size.width: ${size.width}");

    // log("size.height: ${size.height}");

    // log("image height: $imageHeight");
    // log("image width: $imageWidth");
    for (var item in listObject) {
      // final ParagraphBuilder builder = ParagraphBuilder(
      //   ParagraphStyle(
      //       textAlign: TextAlign.left,
      //       fontSize: 16,
      //       textDirection: TextDirection.ltr),
      // );
      // builder.pushStyle(
      //     ui.TextStyle(color: Colors.lightGreenAccent, background: background));

      // for (var i in item.labels) {
      //   builder.addText(i.text);
      // }

      // builder.pop();
      // log("yyyyy: ${item.boundingBox.left} - ${item.boundingBox.top} - ${item.boundingBox.right} - ${item.boundingBox.bottom}");
      // log("aaaaa: ${item.boundingBox.width} - ${item.boundingBox.height} ");

      double left = (item.boundingBox.left) * size.width;
      double top = (item.boundingBox.top) * size.height;
      double right = (item.boundingBox.right) * size.width;
      double bottom = (item.boundingBox.bottom) * size.height;
      // log("1111: left-$left - top-$top - right-$right - bottom-$bottom");

      if (positionCurrentChange != null) {
        log("xxx");
        initPositionMove(
            canvas: canvas,
            paint: paint,
            left: left,
            top: top,
            right: right,
            bottom: bottom);
      } else {
        if (Platform.isAndroid) {
          canvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom),
            paint,
          );
        } else {
          canvas.drawRect(
            Rect.fromLTWH(left, top, right, bottom),
            paint,
          );
        }
      }

      // canvas.drawParagraph(
      //   builder.build()
      //     ..layout(ParagraphConstraints(
      //       width: right,
      //     )),
      //   Offset(left, top),
      // );
    }
  }

  initPositionMove(
      {required Canvas canvas,
      required Paint paint,
      required double left,
      required double top,
      required double right,
      required double bottom}) {
    left = positionCurrentChange!.dx - 50;
    top = positionCurrentChange!.dy - 50;

    // log("22222: left-$left - top-$top - right-$right - bottom-$bottom");
    // log("dx: ${(positionCurrentChange!.dx * size.width)} \ndy: ${(positionCurrentChange!.dy * size.height)}");
    canvas.drawRect(
      Rect.fromLTWH(left, top, 100, 100),
      paint,
    );
    // log("1111: left: $left ===== top: $top ===== right: $right ===== bottom:$bottom");

    // canvas.drawRect(
    //   Rect.fromLTWH(left, top, right, bottom),
    //   paint,
    // );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
