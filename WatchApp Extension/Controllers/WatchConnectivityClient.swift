//
//  WatchConnectivityClient.swift
//  WatchApp Extension
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 16/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import WatchConnectivity
import RxCocoa
import RxSwift
import SwiftyJSON

enum WatchConnectivityClientError : Error {
    case unknownInstruction
}

class WatchConnectivityClient : NSObject {
    
    static let shared = WatchConnectivityClient()
    
    private(set) var dataStore: Datastore 
    private(set) var isConnected = BehaviorRelay(value: false)
    
    fileprivate var profileHandleCache = [String : [(UIImage) -> ()]]()
    
    fileprivate var disposeBag = DisposeBag()
    
    init(dataStore: Datastore = .shared) {
        self.dataStore = dataStore
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
                self.fetchCompetitions()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchProfileImage(profileURL: String, replyHandler: @escaping (UIImage) -> ()) {
        
        if let image = SimpleCache.shared.images[profileURL] {
            replyHandler(image)
            return
        }
        
        if var cachedHandlers = profileHandleCache[profileURL] {
            cachedHandlers.append(replyHandler)
            profileHandleCache[profileURL] = cachedHandlers
            return
        }
        
        profileHandleCache[profileURL] = [replyHandler]
        
        let session = WCSession.default
        
        if session.isReachable {
            session.sendMessage(["instruction" : "fetchProfileImage", "value" : profileURL], replyHandler: { reply in
                if let imageData = reply["value"] as? Data, let image = UIImage(data: imageData) {
                    SimpleCache.shared.images[profileURL] = image
                    if let handlers = self.profileHandleCache[profileURL] {
                        for handler in handlers {
                            handler(image)
                        }
                    }
                    self.profileHandleCache[profileURL] = nil
                }
            })
        }
    }
    
    func fetchCompetitions() {
        
        let session = WCSession.default
        session.sendMessage(["instruction" : "fetchCompetitions"], replyHandler: { reply in
            guard let competitionsInfo = reply["competitions"] as? [[String : Any]] else {
                return
            }
            let competitions = competitionsInfo.map({Competition(json: JSON($0))})
            if self.dataStore.competitions.value != competitions {
                self.dataStore.competitions.accept(competitions)
            }
        }, errorHandler: { (error) in
            print(error)
        })
    }
    
}

extension WatchConnectivityClient : WCSessionDelegate {
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isConnected.accept(session.isReachable)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        isConnected.accept(activationState == .activated)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
    
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        guard let instruction = message["instruction"] as? String else {
            return
        }
        
        if instruction == "competitionsUpdated", let competitions = message["value"] as? [[String : Any]] {
            dataStore.competitions.accept(competitions.map({Competition(json: JSON($0))}))
        }
        
    }
    
}
