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
        super.init()
        
        activate()
        
        dataStore
            .competitions
            .subscribe { event in
                if case let .next(competitions) = event {
                    guard WCSession.isSupported() else {
                        return
                    }
                    let competitionsUpdated = competitions.map({$0.asJSON})
                    WCSession.default.sendMessage(["instruction" : "competitionsUpdated",
                                                   "value" :  competitionsUpdated],
                                                  replyHandler: nil,
                                                  errorHandler: nil)
                }
            }
            .disposed(by: disposeBag)
    }

    fileprivate func activate() {
        
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    fileprivate func fetchCompetitions(_ replyHandler: (([String : Any]) -> Swift.Void)? = nil) {
        
        // Ask competition service for latest competitions
        competitionService
            .fetchCompetitions()
            .subscribe { _ in
                // No need to do anything with the event
            }
            .disposed(by: disposeBag)
    }
    
}


extension WatchConnectivityServer : WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            fetchCompetitions()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        
        guard let instruction = message["instruction"] as? String else {
            replyHandler(["error": WatchConnectivityServerError.unknownInstruction.localizedDescription])
            return
        }
        
        if instruction == "fetchCompetitions" {
            fetchCompetitions(replyHandler)
        }
        
        if let value = message["value"] as? String, let photoURL = URL(string: value), instruction == "fetchProfileImage" {
            competitionService.fetchProfileImage(photoURL: photoURL, replyHandler: { image in
                if let data = UIImageJPEGRepresentation(image.resize(newWidth: 50), 0.1) {
                    replyHandler(["value" : data])
                }
            })
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
}

fileprivate extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
