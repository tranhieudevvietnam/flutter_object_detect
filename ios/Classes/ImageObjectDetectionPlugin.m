#import "ImageObjectDetectionPlugin.h"
#if __has_include(<image_object_detection/image_object_detection-Swift.h>)
#import <image_object_detection/image_object_detection-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "image_object_detection-Swift.h"
#endif

@implementation ImageObjectDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageObjectDetectionPlugin registerWithRegistrar:registrar];
}
@end
