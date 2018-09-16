# BeBetter for iOS and watchOS
### Example of integration between Salesforce and Apple HealthKit

[![Build Status](https://travis-ci.org/mattsrobot/BeBetter.svg?branch=master)](https://travis-ci.org/mattsrobot/BeBetter)

<p float="left">
  <img src="https://github.com/mattsrobot/BeBetter/blob/master/Documentation/bbphone.png?raw=true" alt="Phone App" width="300" height="582" />
  <img src="https://github.com/mattsrobot/BeBetter/blob/master/Documentation/bbwatch.png?raw=true" alt="Watch App" width="200" height="200" />
</p>

### How to build

- Download Xcode from the  <a href="https://itunes.apple.com/gb/app/xcode/id497799835?mt=12">Mac App Store</a>
- Open the BeBetter.xcworkspace in Xcode
- Select the 'WatchApp' scheme

### How to integrate with your Salesforce org

- Create a connected app <a href="https://eu16.salesforce.com/app/mgmt/forceconnectedapps/forceAppEdit.apexp">here</a> 
   - Enable Device Flow **(ticked)**
   - Callback URL	testsfdc:///mobilesdk/detect/oauth/done
   - Require Secret for Web Flow **(not ticked)**
   - Selected OAuth Scopes are api, web, refresh_token, offline_access
- Copy your Consumer Key and paste it inside Constants.swift as **remoteAccessConsumerKey** inside the Xcode project 

### Project Architecture

- Built with the <a href="https://developer.salesforce.com/developer-centers/mobile">Salesforce Mobile SDK</a>
- MVVM (Model, View, ViewModel)
- RxSwift <img src="https://github.com/ReactiveX/RxSwift/raw/master/assets/Rx_Logo_M.png" alt="Miss Electric Eel 2016" width="20" height="20">




      
    
