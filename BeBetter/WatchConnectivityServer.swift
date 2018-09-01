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
    case unknownInstruction
}

class WatchConnectivityServer : NSObject {
    
    private(set) var dataStore: Datastore
    fileprivate var disposeBag = DisposeBag()
    fileprivate var competitionService: CompetitionService
    
    init(competitionService: CompetitionService = CompetitionService(), dataStore: Datastore = .shared) {
        self.competitionService = competitionService
        self.dataStore = dataStore
        dataStore
            .competitions
            .subscribe { event in
                if case let .next(competitions) = event {
                    guard WCSession.isSupported() else { return }
                    let session = WCSession.default
                    guard session.isReachable else { return }
                    session.sendMessage(["instruction" : "competitionsUpdated",
                                         "value" : competitions.map({$0.asJSON}) ],
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
    
    fileprivate func fetchCompetitions(_ replyHandler: (([String : Any]) -> Swift.Void)? = nil) {
        
        // Quickly fetch competitions from cache
        let competitions = dataStore.competitions.value.map({$0.asJSON})
        replyHandler?(["competitions" : competitions])
        
        // Ask competition service for latest competitions
        competitionService
            .fetchCompetitions()
            .subscribe { event in
                // If we get some new competitions, update the datastore.
                if case let .next(competitions) = event {
                    self.dataStore.competitions.accept(competitions)
                }
            }
            .disposed(by: disposeBag)
    }
    
}


extension WatchConnectivityServer : WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        
        guard let instruction = message["instruction"] as? String else {
            replyHandler(["error": WatchConnectivityServerError.unknownInstruction.localizedDescription])
            return
        }
        
        if instruction == "fetchCompetitions" {
            fetchCompetitions(replyHandler)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
}
