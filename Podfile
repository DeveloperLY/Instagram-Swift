source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Instagram-Swift' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Instagram-Swift
  pod 'AVOSCloud'               # 数据存储、短信、云引擎调用等基础服务模块
  pod 'AVOSCloudIM'             # 实时通信模块
  pod 'AVOSCloudCrashReporting' # 崩溃报告模块
  pod 'SnapKit', '~> 4.0.0'
  pod 'ActiveLabel', :git => 'https://github.com/optonaut/ActiveLabel.swift.git', :tag => '0.8.0'

  target 'Instagram-SwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Instagram-SwiftUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
