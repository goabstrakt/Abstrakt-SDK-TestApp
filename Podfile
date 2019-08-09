# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'SDKTestApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SDKTestApp
#  pod 'Abstrakt', :path => '../../abstrakt-sdk-internal'
  pod 'Abstrakt', :git => 'https://github.com/goabstrakt/Abstrakt-iOS-SDK.git'
  pod 'SDWebImage/WebP'
  pod 'DropDown'
  pod 'MBProgressHUD'
  pod 'HockeySDK' #figure out a way to remove HockeyApp from SDK
  pod 'IQKeyboardManager'
  pod 'Toast-Swift', '~> 5.0.0'

  target 'SDKTestAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
