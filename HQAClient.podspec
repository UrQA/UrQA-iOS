#
# Be sure to run `pod lib lint HQAClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HQAClient"
  s.version          = "0.1.0"
  s.summary          = "honeyqa client for iOS Devices"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                     # honeyqa iOS Client
                     Mobile crash report service [link](https://honeyqa.io)
                     DESC

  s.homepage         = "https://github.com/honeyqa/honeyqa-iOS"
  s.license          = 'MIT'
  s.author           = { "devholic" => "devholic@plusquare.com" }
  s.source           = { :git => "https://github.com/honeyqa/honeyqa-iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/groups/1398899177025363/'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'JSONKit-NoWarning', '~> 1.2'
  s.dependency 'KeychainItemWrapper', '~> 1.2'
  s.dependency 'Reachability', '~> 3.2'
  s.ios.preserve_paths = 'Pod/Externals/*.framework'
  s.ios.vendored_frameworks = 'Pod/Externals/CrashReporter.framework'
  s.ios.resource = 'Pod/Externals/CrashReporter.framework'
  s.ios.xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => '"$(PODS_ROOT)/MyPod/MyPodSubdir/Externals"' }
end
