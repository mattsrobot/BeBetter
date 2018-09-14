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
import RxCocoa
import RxSwift

// Fill these in when creating a new Connected Application on Force.com

class AppDelegate : UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate var watchConnectivityServer = WatchConnectivityServer()
    fileprivate var healthMonitor = HealthMonitor()
    fileprivate var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        configureSalesforceSDK()
    }
    
    fileprivate func configureSalesforceSDK() {
        
        SalesforceSwiftSDKManager
            .initSDK()
            .Builder
            .configure { appconfig in
                
                appconfig.oauthScopes = ["web", "api", "refresh_token"]
                appconfig.remoteAccessConsumerKey = Secrets.remoteAccessConsumerKey
                appconfig.oauthRedirectURI = Secrets.OAuthRedirectURI
                
            }.postInit {
                
                SFUserAccountManager.sharedInstance().advancedAuthConfiguration = .require
                
            }.postLaunch { [weak self] launchActionList in
                
                if launchActionList.contains(.alreadyAuthenticated) || launchActionList.contains(.passcodeVerified) || launchActionList.contains(.authenticated) {
                    self?.navigateToCompetitionListScreen()
                }
                
            }.postLogout { [weak self] in
                
                self?.handleSdkManagerLogout()
                
            }.switchUser{ [weak self] fromUser, toUser in
                
                self?.handleUserSwitch(fromUser, toUser: toUser)
                
            }.launchError {  [weak self] error, launchActionList in
                
                self?.initializeAppViewState()
                
                SalesforceSDKManager.shared().launch()
                
            }.done()
    }
    
    // MARK: - App delegate lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
                
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        Theme.shared
            .midnightBlue
            .bind(to: window.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        self.window = window
        
        initializeAppViewState()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
         SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        
         if SFUserAccountManager.sharedInstance().currentUser?.credentials.accessToken != nil {
            
            SFPushNotificationManager.sharedInstance().registerSalesforceNotifications(completionBlock: {
                // Handle success
            }, fail: {
                // Handle failure
            })
         }
    }


    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        // Respond to any push notification registration errors here.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
         return SFUserAccountManager.sharedInstance().handleAdvancedAuthenticationResponse(url, options: options)
    }

    // MARK: - Private methods
    fileprivate func initializeAppViewState() {
        
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.initializeAppViewState()
            }
            return
        }
        
        if SFUserAccountManager.sharedInstance().currentUser == nil {
            navigateToOnboardingScreen()
        } else {
            navigateToCompetitionListScreen()
        }
        
        window?.makeKeyAndVisible()
    }
    
    fileprivate func navigateToOnboardingScreen() {
        
        Theme.shared.apply()
        let rootVC = OnboardingView(with: OnboardingViewModel())
        window?.rootViewController = rootVC
    }
    
    fileprivate func navigateToCompetitionListScreen() {
        
        Theme.shared.apply()
        let rootVC = CompetitionListView(with: CompetitionListViewModel())
        let navVC = BetterNavigationController(rootViewController: rootVC)
        window?.rootViewController = navVC
        healthMonitor.activate()
    }
    
    fileprivate func resetViewState(_ postResetBlock: @escaping () -> ()) {
        
        if let rootViewController = window?.rootViewController, let _ = rootViewController.presentedViewController  {
            rootViewController.dismiss(animated: false, completion: postResetBlock)
            return
        }

        postResetBlock()
    }

    fileprivate func handleSdkManagerLogout() {
        
        SFSDKLogger.log(type(of:self),
                        level: .debug,
                        message: "SFUserAccountManager logged out. Resetting app.")
        
        resetViewState {
            
            self.initializeAppViewState()
            
            var numberOfAccounts : Int;
            let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts()
            numberOfAccounts = (allAccounts!.count);
            
            if numberOfAccounts > 1 {
                let userSwitchVc = SFDefaultUserManagementViewController(completionBlock: {
                    action in
                    self.window?.rootViewController?.dismiss(animated:true, completion: nil)
                })
                if let actualRootViewController = self.window?.rootViewController {
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
    
    fileprivate func handleUserSwitch(_ fromUser: SFUserAccount?, toUser: SFUserAccount?) {
        
        let fromUserName =  fromUser?.userName ?? "<none>"
        let toUserName = toUser?.userName ?? "<none>"
        
        SFSDKLogger.log(type(of:self),
                        level:.debug,
                        message:"SFUserAccountManager changed from user \(String(describing: fromUserName)) to \(String(describing: toUserName)). Resetting app.")
        
        resetViewState {
            self.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
    }
}
