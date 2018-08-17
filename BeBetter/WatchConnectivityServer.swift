//
//  WatchConnectivityServer.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 13/8/18.
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
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var competitionService: CompetitionService
    
    init(competitionService: CompetitionService = CompetitionService()) {
        self.competitionService = competitionService
    }

    func activate() {
        
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    fileprivate func fetchFriends(_ replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        competitionService
            .fetchFriends().map({$0.map({$0.asJSON})})
            .subscribe { event in
                if case let .next(friends) = event {
                    replyHandler(["friends" : friends])
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
