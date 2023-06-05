#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'media_tool_darwin'
  s.version          = '0.0.1'
  s.summary          = 'A Darwin implementation of the media_tool plugin.'
  s.description      = <<-DESC
  A Darwin implementation of the media_tool plugin.
                       DESC
  s.homepage         = 'https://github.com/starkdmi/media_tool_flutter'
  s.license          = { :type => 'GPLv3', :file => '../LICENSE' }
  s.author           = { 'Dmitry Starkov' => 'starkdev@icloud.com' }
  s.source           = { :path => '.' }  
  s.source_files = 'Classes/**/*'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  s.dependency 'MediaToolSwift', '1.0.2'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.8'
end
