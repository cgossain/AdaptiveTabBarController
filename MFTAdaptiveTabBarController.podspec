Pod::Spec.new do |s|
  s.name             = 'MFTAdaptiveTabBarController'
  s.version          = '1.1.0'
  s.summary          = 'An adaptive view controller that adapts between a compact and regualar version of a tab bar controller.'
  s.description      = <<-DESC
                       The MFTAdaptiveTabBarController offers an adaptive view controller that can be installed as the root view controller of an application.

                       When in a horizontally compact environment, the controller installs a UITabBarController to its interface. When horizontally regular, the controller installs a MFTVerticalTabBarController to its interface. The MFTVerticalTabBarController is a view controller that provides a tab bar on the left side of its interface, and is more appropriate in regular environments.
                       DESC
  s.homepage         = 'https://github.com/cgossain/MFTAdaptiveTabBarController'
  s.license          = 'MIT'
  s.author           = { 'Christian Gossain' => 'cgossain@gmail.com' }
  s.source           = { :git => 'https://github.com/cgossain/MFTAdaptiveTabBarController.git', :tag => s.version.to_s }
  s.platform         = :ios, '11.4'
  s.swift_version = '5.0'
  s.source_files = 'MFTAdaptiveTabBarController/Classes/**/*.swift'
  s.resource = 'MFTAdaptiveTabBarController/Assets/*.xcassets'
  s.dependency 'AppController'
end
