#
# Be sure to run `pod lib lint GSSAdaptiveTabBarController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GSSAdaptiveTabBarController"
  s.version          = "0.1.0"
  s.summary          = "An adaptive tab bar controller implementation."
  s.description      = <<-DESC
                       This project implements an adaptive tab bar controller. Compact environments use the standard UITabBarController, but regular environments use custom tab bar controlller with the tab bar located on the left side of the view. This adaptive tab bar controller takes care of transitioning to the correct controller when the environment changes (i.e. rotation, split screen multitasking, etc.).
                       DESC

  s.homepage         = "https://github.com/<GITHUB_USERNAME>/GSSAdaptiveTabBarController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Christian Gossain" => "Christian Gossain" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/GSSAdaptiveTabBarController.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GSSAdaptiveTabBarController' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'AppController', '~> 0.3.0'
  s.dependency 'SnapKit'
end
