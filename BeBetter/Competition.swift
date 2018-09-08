//
//  Competition.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Competition {
    
    fileprivate struct Constants {
        static let activeEnergyKey = "Active_Energy__c"
        static let stepsKey = "Steps__c"
        static let distanceKey = "Distance__c"
        static let userKey = "User__r"
        static let nameKey = "Name"
        static let photoURLKey = "FullPhotoUrl"
    }

    let name: String
    let participants: [CompetitionParticipant]
    
    init(name: String, participants: [CompetitionParticipant]) {
        self.name = name
        self.participants = participants
    }
    
    init(json: JSON) {
        name = ""
        participants = []
    }
    
    var asJSON: [String : Any] {
        return ["name" : name,
                "participants" : participants.map({$0.asJSON})]
    }
}

extension Competition {
    
    static fileprivate func competition(name: String, records: [[String : Any]], key: String) -> Competition {
        
        // Default to 1 to avoid divide by zero error
        
        let maxScore = records
            .map({ $0[key] as? Int ?? 1 })
            .sorted()
            .last ?? 1
        
        let participants:[CompetitionParticipant] = records.map { row in
        
            let user = row[Constants.userKey] as? [String : Any]
            let name = user?[Constants.nameKey] as? String ?? ""
            let photoURLString = user?[Constants.photoURLKey] as? String ?? ""
            let photoURL = URL(string: photoURLString)
            
            let person = Person(name: name, photoURL: photoURL)
            let score = row[key] as? Int ?? 1
            let rank = CGFloat(score)/CGFloat(maxScore)
            
            return CompetitionParticipant(person: person, score: score, rank: rank)
        }
        
        return Competition(name: name, participants: participants)
    }
    
    static func energyBurnedCompetition(_ records: [[String : Any]]) -> Competition {
        return competition(name: LocalizedStrings.CompetitionListScreen.Categories.energyBurned,
                           records: records,
                           key: Constants.activeEnergyKey)
    }
    
    static func stepsCompetition(_ records: [[String : Any]]) -> Competition {
        return competition(name: LocalizedStrings.CompetitionListScreen.Categories.stepCount,
                           records: records,
                           key: Constants.stepsKey)
    }
    
    static func distanceWalkingRunningCompetition(_ records: [[String : Any]]) -> Competition {
        return competition(name: LocalizedStrings.CompetitionListScreen.Categories.runningDistance,
                           records: records,
                           key: Constants.distanceKey)
    }
    
}
