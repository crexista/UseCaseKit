# coding: utf-8
platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!

source 'https://cdn.cocoapods.org/'

target 'UseCaseKit' do
  pod 'SwiftLint', '0.45.1'
  target 'UseCaseKitTests' do
    pod 'Quick'
    pod 'Nimble'
  end
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
