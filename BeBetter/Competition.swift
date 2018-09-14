//
//  Competition.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SwiftyJSON
import HealthKit

fileprivate struct Constants {
    static let activeEnergyKey = "Active_Energy__c"
    static let stepsKey = "Steps__c"
    static let distanceKey = "Distance__c"
    static let userKey = "User__r"
    static let nameKey = "Name"
    static let photoURLKey = "FullPhotoUrl"
}

struct Competition {
    
    enum Category {
        
        case steps
        case distance
        case energy
        
        /// The field used to store data in Salesforce
        var soqlField : String {
            switch self {
            case .steps: return Constants.stepsKey
            case .distance: return Constants.distanceKey
            case .energy: return Constants.activeEnergyKey
            }
        }
        
        /// The localized name to show
        var localizedName : String {
            switch self {
            case .steps: return LocalizedStrings.CompetitionListScreen.Categories.stepCount
            case .distance: return LocalizedStrings.CompetitionListScreen.Categories.runningDistance
            case .energy: return LocalizedStrings.CompetitionListScreen.Categories.energyBurned
            }
        }
        
        /// The corresponding HealthKit identifier
        var identifier: HKQuantityTypeIdentifier {
            switch self {
            case .steps: return .stepCount
            case .distance: return .distanceWalkingRunning
            case .energy: return .activeEnergyBurned
            }
        }
        
    }

    let name: String
    let participants: [CompetitionParticipant]
    
    init(name: String, participants: [CompetitionParticipant]) {
        self.name = name
        self.participants = participants
    }
    
    init(json: JSON) {
        name = json["name"].string ?? ""
        
        participants = json["participants"].array?.map({CompetitionParticipant(json: $0)}) ?? []
    }
    
    var asJSON: [String : Any] {
        return ["name" : name,
                "participants" : participants.map({$0.asJSON})]
    }
}

extension Competition : Equatable {
    static func == (lhs: Competition, rhs: Competition) -> Bool {
        return lhs.name == rhs.name &&
            lhs.participants == rhs.participants
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
    
    static fileprivate func competition(for category: Category, using records: [[String : Any]]) -> Competition {
        return competition(name: category.localizedName,
                           records: records,
                           key: category.soqlField)
    }
    
    static func extract(_ records: [[String : Any]], categories: [Category] = [.distance, .steps, .energy]) -> [Competition] {
        return categories.map({Competition.competition(for: $0, using: records)})
    }
    
}

extension HKQuantityTypeIdentifier {
    
    /// The localized name to show
    var category : Competition.Category? {
        switch self {
        case .stepCount: return .steps
        case .distanceWalkingRunning: return .distance
        case .activeEnergyBurned: return .energy
        default: return nil
        }
    }
}
