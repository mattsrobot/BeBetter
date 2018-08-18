//
//  WatchConnectivityClient.swift
//  WatchApp Extension
//
//  Created by Matthew Wilkinson on 16/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import WatchConnectivity
import RxCocoa
import RxSwift
import SwiftyJSON

class WatchConnectivityClient : NSObject {
    
    private(set) var friends: BehaviorRelay<[Person]> = BehaviorRelay(value: [])
    private(set) var isConnected = BehaviorRelay(value: false)
    
    fileprivate var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        activate()
    }
    
    func activate() {
        
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        
        isConnected
            .filter({$0})
            .subscribe({ _ in
                self.fetchFriends()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchFriends() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["instruction" : "fetchFriends"],
                                replyHandler: { reply in
                                    guard let friendsInfo = reply["friends"] as? [[String : Any]] else {
                                        return
                                    }
                                    let friends = friendsInfo.map({Person(json: JSON($0))})
                                    self.friends.accept(friends)
            }, errorHandler: nil)
        }
    }
    
}

extension WatchConnectivityClient : WCSessionDelegate {
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isConnected.accept(session.isReachable)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        isConnected.accept(activationState == .activated)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        
    }
    
}
