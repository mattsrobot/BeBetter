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
    }
    
    func fetchFriends() -> Observable<[Person]> {
        return Observable.create { observer in
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(["instruction" : "fetchFriends"],
                                    replyHandler: { reply in
                                        guard let friendsInfo = reply["friends"] as? [[String : Any]] else {
                                            observer.on(.completed)
                                            return
                                        }
                                        let friends = friendsInfo.map({Person(json: JSON($0))})
                                        observer.onNext(friends)
                                    }, errorHandler: { error in
                                        observer.onError(error)
                                    })
            } else {
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
    
}

extension WatchConnectivityClient : WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        
    }
    
}
