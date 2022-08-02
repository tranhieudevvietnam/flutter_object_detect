#import "FlutterObjectDetectPlugin.h"
#if __has_include(<flutter_object_detect/flutter_object_detect-Swift.h>)
#import <flutter_object_detect/flutter_object_detect-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_object_detect-Swift.h"
#endif

@implementation FlutterObjectDetectPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterObjectDetectPlugin registerWithRegistrar:registrar];
}
@end
