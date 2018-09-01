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
        let participants:[CompetitionParticipant] = records.map { row in
            let user = row["User__r"] as? [String : Any]
            let name = user?["Name"] as? String ?? ""
            let person = Person(name: name)
            let distanceWalkingRunning = row[key] as? Int ?? 0
            let participant = CompetitionParticipant(person: person, score: distanceWalkingRunning)
            return participant
        }
        return Competition(name: name, participants: participants)
    }
    
    static func distanceWalkingRunningCompetition(_ records: [[String : Any]]) -> Competition {
        return competition(name: LocalizedStrings.CompetitionListScreen.Categories.runningDistance,
                           records: records,
                           key: "Distance__c")
    }
    
}
