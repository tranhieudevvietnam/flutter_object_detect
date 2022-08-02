import 'package:flutter/material.dart';

class DetectedObject {
  /// Tracking ID of object. If tracking is disabled it is null.
  final int? trackingId;

  /// Rect that contains the detected object.
  final Rect boundingBox;

  /// List of [Label], identified for the object.
  final List<Label> labels;

  final num? imageWidth;
  final num? imageHeight;

  /// Constructor to create an instance of [DetectedObject].
  DetectedObject(
      {required this.boundingBox,
      required this.labels,
      required this.trackingId,this.imageWidth,this.imageHeight});

  /// Returns an instance of [DetectedObject] from a given [json].
  factory DetectedObject.fromJson(Map<dynamic, dynamic> json) {
    final rect = RectJson.fromJson(json['rect']);
    final trackingId = json['trackingId'];
    final labels = <Label>[];
    for (final dynamic label in json['labels']) {
      labels.add(Label.fromJson(label));
    }
    return DetectedObject(
      boundingBox: rect,
      labels: labels,
      trackingId: trackingId,
      imageWidth: json['imageWidth'],
      imageHeight: json['imageHeight'],
    );
  }
}

/// A label that describes an object detected in an image.
class Label {
  /// Gets the confidence of this label.
  /// Its range depends on the classifier model used, but by convention it should be [0, 1].
  final double confidence;

  /// Gets the index of this label.
  final int index;

  /// Gets the text of this label.
  final String text;

  /// Constructor to create an instance of [Label].
  Label({required this.confidence, required this.index, required this.text});

  /// Returns an instance of [Label] from a given [json].
  factory Label.fromJson(Map<dynamic, dynamic> json) => Label(
        confidence: json['confidence'],
        index: json['index'],
        text: json['text'],
      );
}

extension RectJson on Rect {
  /// Returns an instance of [Rect] from a given [json].
  static Rect fromJson(Map<dynamic, dynamic> json) {
    return Rect.fromLTRB(
      json['left']?.toDouble() ?? 0,
      json['top']?.toDouble() ?? 0,
      json['right']?.toDouble() ?? 0,
      json['bottom']?.toDouble() ?? 0,
    );
  }
}
