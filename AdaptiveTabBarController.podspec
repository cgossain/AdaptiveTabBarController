Pod::Spec.new do |s|
  s.name             = 'AdaptiveTabBarController'
  s.version          = '2.3.1'
  s.summary          = 'A UITabBarController replacement with support for floating action button and adaptivity between trait environments on iOS, written in Swift.'
  s.description      = <<-DESC
  The AdaptiveTabBarController is an adaptive view controller that can be installed as 
  the root view controller of your application. It provides a floating action button which
  can have actions presented when tapped. It uses the built in UITabBarController while in
  a compact trait environment, and a custom built vertical tab bar controller while in a
  regular trait environment. The controller automatically adapts between the two as the
  trait environment changes (e.g. split screen adjustments on iPad)
                       DESC

  s.homepage         = 'https://github.com/cgossain/AdaptiveTabBarController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cgossain' => 'cgossain@gmail.com' }
  s.source           = { :git => 'https://github.com/cgossain/AdaptiveTabBarController.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '11.4'
  s.source_files = 'AdaptiveTabBarController/Classes/**/*'
  s.resource_bundles = {
    'LibAssets' => ['AdaptiveTabBarController/Assets/**/*']
  }
  s.frameworks = 'UIKit'
  s.dependency 'AppController'
end
