project 'BeBetter.xcodeproj'

def salesforce
    pod 'SalesforceAnalytics', :path => 'mobile_sdk/SalesforceMobileSDK-iOS'
    pod 'SalesforceSDKCore', :path => 'mobile_sdk/SalesforceMobileSDK-iOS'
    pod 'SmartStore', :path => 'mobile_sdk/SalesforceMobileSDK-iOS'
    pod 'SmartSync', :path => 'mobile_sdk/SalesforceMobileSDK-iOS'
    pod 'SalesforceSwiftSDK', :path => 'mobile_sdk/SalesforceMobileSDK-iOS'
    pod 'PromiseKit', :git => 'https://github.com/mxcl/PromiseKit', :tag => '5.0.3'
end

def common_pods
    source 'https://github.com/CocoaPods/Specs.git'
    
    use_frameworks!
    inhibit_all_warnings!
    
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'SwiftyJSON', '~> 4.0'
    pod 'AlamofireImage', '~> 3.3'
end

target 'BeBetter' do
    platform :ios, '10.0'
    common_pods
    pod 'SnapKit', '~> 4.0.0'
    salesforce
end

target 'BeBetterTests' do
    platform :ios, '10.0'
    common_pods
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest',     '~> 4.0'
end

target 'WatchApp Extension' do
    platform :watchos, '4.0'
    common_pods
end




# Fix for xcode9/fmdb/sqlcipher/cocoapod issue - see https://discuss.zetetic.net/t/ios-11-xcode-issue-implicit-declaration-of-function-sqlite3-key-is-invalid-in-c99/2198/27
post_install do | installer |
  print "SQLCipher: link Pods/Headers/sqlite3.h"
  system "mkdir -p Pods/Headers/Private && ln -s ../../SQLCipher/sqlite3.h Pods/Headers/Private"
end
