import Flutter
//import MLKitObjectDetectionCustom
//import MLKitObjectDetection
//import MLKitCommon
//import MLKitVision
import CoreFoundation



public class SwiftFlutterObjectDetectPlugin: NSObject, FlutterPlugin {
    
    final var loadModelStr="load_model"
    final var detectImageStr="detect_image"
    final var detectImageStrV2="detect_image_v2"
    
    //    var options: CustomObjectDetectorOptions!
    
    
    var optionsTensorflow: ObjectDetectionHelper!
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_object_detect", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterObjectDetectPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if(call.method==loadModelStr){
            if let args = call.arguments as? Dictionary<String, Any>{
                let pathModel = args["pathModel"] as? String
                if(pathModel != nil){
                    loadModel(localModelFilePath: pathModel!)
                    result("load model success")
                }
                
            }else{
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            
        }else if(call.method==detectImageStr){
            if let args = call.arguments as? Dictionary<String, Any>{
                let pathImage = args["pathFile"] as? String
                if(pathImage != nil){
                    //                    detectImage(filePath: pathImage!, result: result)
                    detectImageV2(filePath: pathImage!, result: result)
                }else{
                    result(FlutterError.init(code: "bad args", message: "path image not null", details: nil))
                }
                
            }else{
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
        }else if(call.method==detectImageStrV2){
            if let args = call.arguments as? Dictionary<String, Any>{
                let pathImage = args["pathFile"] as? String
                if(pathImage != nil){
                    detectImageV2(filePath: pathImage!, result: result)
                }else{
                    result(FlutterError.init(code: "bad args", message: "path image not null", details: nil))
                }
                
            }else{
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
        }
        
        
        else{
            result("iOS " + UIDevice.current.systemVersion)
        }
        
        
    }
    
    
    public func loadModel(localModelFilePath: String){
        //        let localModel = LocalModel(path: localModelFilePath)
        //        options = CustomObjectDetectorOptions(localModel: localModel)
        //        options.detectorMode = .singleImage
        //        options.shouldEnableClassification = true
        //        options.shouldEnableMultipleObjects = true
        //        options.classificationConfidenceThreshold = NSNumber(value: 0.5)
        //        options.maxPerObjectLabelCount = 3
        
        
        loadModelV2(modelPath: localModelFilePath)
    }
    public func detectImage(filePath: String, result: @escaping FlutterResult){
        //        let objectDetector = ObjectDetector.objectDetector(options: options)
        //
        //        let image = filePathToVisionImage(filePath: filePath)
        //
        //
        //        objectDetector.process(image) { objects, error in
        //            guard error == nil, let objects = objects, !objects.isEmpty else {
        //                // Handle the error.
        //                return
        //            }
        //            // Show results.
        //
        //            let objectsData = NSMutableArray();
        //
        //            let labels=NSMutableArray();
        //            for  object in objects {
        //                for label in object.labels{
        //                    labels.add([
        //                        "index": label.index,
        //                        "text": label.text,
        //                        "confidence": label.confidence ])
        //                }
        //                let data = NSMutableDictionary();
        //                data.addEntries(from: [
        //                    "rect" : ["left" : object.frame.origin.x,
        //                              "top" : object.frame.origin.y,
        //                              "right" : object.frame.origin.x + object.frame.size.width,
        //                              "bottom" : object.frame.origin.y + object.frame.size.height]
        //                    ,
        //                    "labels" : labels
        //                ])
        //                if ( object.trackingID != nil) {
        //                    data["trackingId"] = object.trackingID;
        //                }
        //                objectsData.add(data)
        //
        //            }
        //
        //            result(objectsData)
        //        }
    }
    
    
    //    public func filePathToVisionImage( filePath: String) -> VisionImage {
    //        let image=UIImage.init(contentsOfFile: filePath)!
    //        let  visionImage  = VisionImage.init(image: image)
    //        visionImage.orientation=image.imageOrientation
    //        return visionImage;
    //    }
    
    
    
    
    ///tensorflow
    public func loadModelV2 (modelPath: String){
        optionsTensorflow = ObjectDetectionHelper(
            modelPath: modelPath,
            threadCount: ConstantsDefault.threadCount,
            scoreThreshold: ConstantsDefault.scoreThreshold,
            maxResults: ConstantsDefault.maxResults
        )
    }
    
    func detectImageV2(filePath: String, result: @escaping FlutterResult) {
        let image = UIImage.init(contentsOfFile: filePath)!
        let pixelBuffer = pixelBufferFromImage(image: image)
        print(image.size.width)
        print(image.size.height)
        if pixelBuffer != nil{
            let  resultData : Result? = optionsTensorflow?.detect(frame: pixelBuffer!)
            let objectsData = NSMutableArray();
            
            let labels=NSMutableArray();
            for  object in resultData!.detections {
                
                for label in object.categories {
                    labels.add([
                        "index": label.index,
                        "text": label.label ?? "Object",
                        "confidence": label.score ])
                }
                let data = NSMutableDictionary();
                
                data.addEntries(from: [
                    "rect" : ["left" :  (object.boundingBox.origin.x / image.size.width) ,
                              "top" :   (object.boundingBox.origin.y / image.size.height),
                              "right" :  (object.boundingBox.size.width / image.size.width),
                              "bottom" : (object.boundingBox.size.height / image.size.height)
                             ]
                    ,
                    "labels" : labels,
                    "imageWidth": image.size.width,
                    "imageHeight": image.size.height
                ])
                objectsData.add(data)
                
            }
            
            result(objectsData)
        }
        
        
    }
    
    
    
    
    
    func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer? {
        
        
        let ciimage = CIImage(image: image)
        //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
        let tmpcontext = CIContext(options: nil)
        let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
        
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        
        
        let width = cgimage!.width
        let height = cgimage!.height
        
        
        
        var pxbuffer: CVPixelBuffer?
        // if pxbuffer = nil, you will get status = -6661
//        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
//                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
//        status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
         CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
         CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
//        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
//                context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
        
        
        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
//       status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
   
        return pxbuffer;
        
    }
    
    
    
}




