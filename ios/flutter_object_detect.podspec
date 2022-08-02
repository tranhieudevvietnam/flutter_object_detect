#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_object_detect.podspec` to validate before publishing.
#


pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = library_version
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  s.dependency 'Flutter'
  # s.dependency 'GoogleMLKit/ObjectDetection'
  # s.dependency 'GoogleMLKit/ObjectDetectionCustom'

  # s.dependency 'GoogleMLKit/BarcodeScanning'
  # s.dependency 'GoogleMLKit/ObjectDetection', '3.1.0'
  # s.dependency 'GoogleMLKit/ObjectDetectionCustom', '3.1.0'

  s.dependency 'TensorFlowLiteTaskVision'




  # s.dependency 'GoogleMLKit/LinkFirebase'
  s.platform = :ios, '10.0'
  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.swift_version = '5.0'
  s.library = 'c++'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
