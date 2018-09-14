//
//  CompetitionParticipant.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SwiftyJSON

struct CompetitionParticipant {
    
    let person: Person
    let score: Int
    let rank: CGFloat // value between 0...1
    
    init(person: Person, score: Int, rank: CGFloat) {
        self.person = person
        self.score = score
        self.rank = rank
    }
    
    init(json: JSON) {
        person = Person(json: JSON(json["person"].dictionary ?? [:]))
        score = json["score"].int ?? 0
        rank = CGFloat(json["rank"].double ?? 0)
    }

    var asJSON: [String : Any] {
        return ["person" : person.asJSON,
                "score" : score,
                "rank" : rank]
    }
}

extension CompetitionParticipant : Equatable {
    static func == (lhs: CompetitionParticipant, rhs: CompetitionParticipant) -> Bool {
        return lhs.person == rhs.person &&
            lhs.score == rhs.score &&
            lhs.rank == rhs.rank
    }
}
