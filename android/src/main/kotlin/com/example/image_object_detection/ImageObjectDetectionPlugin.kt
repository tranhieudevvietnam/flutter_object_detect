package com.example.image_object_detection

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.RectF
import android.widget.Toast
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.tensorflow.lite.support.label.Category
import org.tensorflow.lite.task.vision.detector.Detection
import java.io.File

/** ImageObjectDetectionPlugin */
class ImageObjectDetectionPlugin: FlutterPlugin, MethodCallHandler,ObjectDetectorHelper.DetectorListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var result : Result
  private lateinit var context: Context
  private lateinit var objectDetectorHelper: ObjectDetectorHelper
  private var imageHeight =0;
  private var imageWidth =0;

  private lateinit var bitmapBuffer: Bitmap

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "image_object_detection")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    objectDetectorHelper = ObjectDetectorHelper(
      context = context,
      objectDetectorListener = this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    // if (call.method == "getPlatformVersion") {
    //   result.success("Android ${android.os.Build.VERSION.RELEASE}")
    // } else {
    //   result.notImplemented()
    // }
      this.result=result;
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }else {
      if (call.method == "detect_image") {
        detectObjectOnImage(call,result)
      }  else {
        if(call.method == "load_model"){
          val pathModel = call.argument<String>("pathModel").toString()
          objectDetectorHelper.setupObjectDetector(pathModel)
        }else{
          result.notImplemented()
        }
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


  private fun detectObjectOnImage(@NonNull call: MethodCall, @NonNull result: Result){
    val path: String = call.argument<String>("pathFile").toString()
    val imgFile = File(path)
    if (imgFile.exists()) {
      val bitMap= BitmapFactory.decodeFile(imgFile.absolutePath)
      getWidthHeight(imgFile)

      objectDetectorHelper.detect(bitMap, 90)
    }
  }

  override fun onError(error: String) {
    Toast.makeText(context, error, Toast.LENGTH_SHORT).show()

  }


  private fun getWidthHeight(file: File){
    val options = BitmapFactory.Options()
    options.inJustDecodeBounds = true

    BitmapFactory.decodeFile(file.absolutePath, options)
     imageHeight = options.outHeight
     imageWidth = options.outWidth
//    val bitMap= BitmapFactory.decodeFile(file.absolutePath)
//
//      bitmapBuffer = Bitmap.createBitmap(
//        options.outWidth,
//        options.outHeight,
//        Bitmap.Config.ARGB_8888
//      )
//
//
//    val aaa= bitmapBuffer.copyPixelsFromBuffer(bitMap.);

  }

  override fun onResults(
    results: MutableList<Detection>?,
    inferenceTime: Long,
    imageHeight: Int,
    imageWidth: Int
  ) {
    if(results!=null) {
      val objectMap: HashMap<String, Any?> = HashMap()
      var objects: List<Map<String, Any?>> = ArrayList()
      for(re: Detection in results){
        val mapObject: MutableMap<String, Any?> = HashMap()
        addData(mapObject,re.boundingBox,re.categories)
        objects+=mapObject
      }

      objectMap["results"] = objects
      objectMap["inferenceTime"] = inferenceTime
      objectMap["imageWidth"] = imageWidth
      objectMap["imageHeight"] = imageHeight

      this.result.success(objectMap)
    }
  }


  private fun addData(
    addTo: MutableMap<String, Any?>,
    rect: RectF,
    labelList: List<Category>,
  ) {
    val labels: MutableList<Map<String, Any>> = ArrayList()
    addLabels(labels, labelList)
    addTo["rect"] = getBoundingPoints(rect)
    addTo["labels"] = labels
    addTo["imageWidth"] = imageWidth
    addTo["imageHeight"] = imageHeight
  }


  private fun getBoundingPoints( rect: RectF): Map<String, Float>? {
    val frame: MutableMap<String, Float> = HashMap()
    frame["left"] = rect.left/imageWidth
    frame["top"] = rect.top/imageHeight
    frame["right"] = rect.right/imageWidth
    frame["bottom"] = rect.bottom/imageHeight
    return frame
  }

  private fun addLabels(
    labels: MutableList<Map<String, Any>>,
    labelList: List<Category>
  ) {
    for (label in labelList) {
      val labelData: MutableMap<String, Any> = HashMap()
      labelData["index"] = label.index
      labelData["text"] = label.label
      labelData["confidence"] = label.score
      labels.add(labelData)
    }
  }

}
