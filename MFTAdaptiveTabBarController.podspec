Pod::Spec.new do |s|
  s.name             = 'MFTAdaptiveTabBarController'
  s.version          = '0.2'
  s.summary          = 'An adaptive view controller that adapts between a compact and regualar version of a tab bar controller.'
  s.description      = <<-DESC
                       The MFTAdaptiveTabBarController offers an adaptive view controller that can be installed as the root view controller of an application.

                       When in a horizontally compact environment, the controller installs a UITabBarController to its interface. When horizontally regular, the controller installs a MFTVerticalTabBarController to its interface. The MFTVerticalTabBarController is a view controller that provides a tab bar on the left side of its interface, and is more appropriate in regular environments.
                       DESC
  s.homepage         = 'https://github.com/cgossain/MFTAdaptiveTabBarController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christian Gossain' => 'Christian Gossain' }
  s.source           = { :git => 'https://github.com/cgossain/MFTAdaptiveTabBarController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.3'
  s.source_files = 'MFTAdaptiveTabBarController/Classes/**/*'
  s.resource = 'MFTAdaptiveTabBarController/Assets/*.xcassets'
  s.dependency 'AppController'
end
