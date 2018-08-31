//
//  WatchConnectivityServer.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import WatchConnectivity
import RxCocoa
import RxSwift

enum WatchConnectivityServerError : Error {
    case unknownInsturction
}

class WatchConnectivityServer : NSObject {
    
    private(set) var dataStore: Datastore
    fileprivate var disposeBag = DisposeBag()
    fileprivate var competitionService: CompetitionService
    
    init(competitionService: CompetitionService = CompetitionService(), dataStore: Datastore = .shared) {
        self.competitionService = competitionService
        self.dataStore = dataStore
        dataStore
            .friends
            .subscribe { event in
                if case let .next(friends) = event {
                    guard WCSession.isSupported() else { return }
                    let session = WCSession.default
                    guard session.isReachable else { return }
                    session.sendMessage(["instruction" : "friendsUpdated",
                                         "value" : friends.map({$0.asJSON}) ],
                                        replyHandler: nil,
                                        errorHandler: nil)
                }
            }
            .disposed(by: disposeBag)
    }

    func activate() {
        
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    fileprivate func fetchFriends(_ replyHandler: (([String : Any]) -> Swift.Void)? = nil) {
        
        // Quickly fetch friends from cache
        let friends = dataStore.friends.value.map({$0.asJSON})
        replyHandler?(["friends" : friends])
        
        // Ask competition service for latest friends
        competitionService
            .fetchFriends()
            .subscribe { event in
                // If we get some new friends, update the datastore.
                if case let .next(friends) = event {
                    self.dataStore.friends.accept(friends)
                }
            }
            .disposed(by: disposeBag)
    }
    
}


extension WatchConnectivityServer : WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        
        guard let instruction = message["instruction"] as? String else {
            replyHandler(["error": WatchConnectivityServerError.unknownInsturction.localizedDescription])
            return
        }
        
        if instruction == "fetchFriends" {
            fetchFriends(replyHandler)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
}
