/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore
import SalesforceSwiftSDK
import WatchConnectivity

// Fill these in when creating a new Connected Application on Force.com

class AppDelegate : UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate var watchConnectivityServer = WatchConnectivityServer()
    fileprivate var healthMonitor = HealthMonitor()
    
    override init() {
        super.init()
        
        SalesforceSwiftSDKManager.initSDK().Builder.configure { appconfig in
            appconfig.oauthScopes = ["web", "api", "refresh_token"]
            appconfig.remoteAccessConsumerKey = Secrets.remoteAccessConsumerKey
            appconfig.oauthRedirectURI = Secrets.OAuthRedirectURI
        }.postInit {
             SFUserAccountManager.sharedInstance().advancedAuthConfiguration = .require
        }.postLaunch { [weak self] launchActionList in
            guard let `self` = self else {
                return
            }
            let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            SalesforceSwiftLogger.log(type(of:self),
                                      level: .info,
                                      message:"Post-launch: launch actions taken: \(launchActionString)")
            
            self.setupRootViewController()
        }.postLogout {  [weak self] in
            self?.handleSdkManagerLogout()
        }.switchUser{ [weak self] fromUser, toUser in
            self?.handleUserSwitch(fromUser, toUser: toUser)
        }.launchError {  [weak self] error, launchActionList in
            guard let `self` = self else {
                return
            }
            SFSDKLogger.log(type(of:self),
                            level: .error,
                            message: "Error during SDK launch: \(error.localizedDescription)")
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
        .done()
    }
    
    // MARK: - App delegate lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        watchConnectivityServer.activate()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = Theme.shared.midnightBlue.value
        self.initializeAppViewState();
        
        
        let loginViewConfig = SFSDKLoginViewControllerConfig()
        loginViewConfig.showSettingsIcon = false
        loginViewConfig.showNavbar = true
        loginViewConfig.navBarColor = Theme.shared.midnightBlue.value
        loginViewConfig.navBarTextColor = .white
        loginViewConfig.navBarFont = UIFont(name: "Ariel", size: 16.0)
        SFUserAccountManager.sharedInstance().loginViewControllerConfig = loginViewConfig
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        //
        // Uncomment the code below to register your device token with the push notification manager
        //
        //
        // SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        // if (SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken != nil)
        // {
        //    SFPushNotificationManager.sharedInstance().registerForSalesforceNotifications()
        // }
    }


    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        // Respond to any push notification registration errors here.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
         return  SFUserAccountManager.sharedInstance().handleAdvancedAuthenticationResponse(url, options: options)
    }

    // MARK: - Private methods
    func initializeAppViewState()
    {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self.initializeAppViewState()
            }
            return
        }
        Theme.shared.apply()
        let rootVC = OnboardingView(with: OnboardingViewModel())
        self.window!.rootViewController = rootVC
        self.window!.makeKeyAndVisible()
    }
    
    func setupRootViewController()
    {
        Theme.shared.apply()
        let rootVC = CompetitionListView(with: CompetitionListViewModel())
        let navVC = BetterNavigationController(rootViewController: rootVC)
        self.window!.rootViewController = navVC
        watchConnectivityServer.activate()
        healthMonitor.activate()
    }
    
    func resetViewState(_ postResetBlock: @escaping () -> ())
    {
        if let rootViewController = self.window!.rootViewController {
            if let _ = rootViewController.presentedViewController {
                rootViewController.dismiss(animated: false, completion: postResetBlock)
                return
            }
        }

        postResetBlock()
    }

    func handleSdkManagerLogout()
    {
        SFSDKLogger.log(type(of:self), level:.debug, message: "SFUserAccountManager logged out.  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()

            // Multi-user pattern:
            // - If there are two or more existing accounts after logout, let the user choose the account
            //   to switch to.
            // - If there is one existing account, automatically switch to that account.
            // - If there are no further authenticated accounts, present the login screen.
            //
            // Alternatively, you could just go straight to re-initializing your app state, if you know
            // your app does not support multiple accounts.  The logic below will work either way.
            
            var numberOfAccounts : Int;
            let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts()
            numberOfAccounts = (allAccounts!.count);
            
            if numberOfAccounts > 1 {
                let userSwitchVc = SFDefaultUserManagementViewController(completionBlock: {
                    action in
                    self.window!.rootViewController!.dismiss(animated:true, completion: nil)
                })
                if let actualRootViewController = self.window!.rootViewController {
                    actualRootViewController.present(userSwitchVc, animated: true, completion: nil)
                }
            } else {
                if (numberOfAccounts == 1) {
                    SFUserAccountManager.sharedInstance().currentUser = allAccounts![0]
                }
                SalesforceSDKManager.shared().launch()
            }
        }
    }
    
    func handleUserSwitch(_ fromUser: SFUserAccount?, toUser: SFUserAccount?)
    {
        let fromUserName = (fromUser != nil) ? fromUser?.userName : "<none>"
        let toUserName = (toUser != nil) ? toUser?.userName : "<none>"
        SFSDKLogger.log(type(of:self), level:.debug, message:"SFUserAccountManager changed from user \(String(describing: fromUserName)) to \(String(describing: toUserName)).  Resetting app.")
        self.resetViewState { () -> () in
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
    }
}
