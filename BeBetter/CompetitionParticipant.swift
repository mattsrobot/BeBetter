//
//  CompetitionParticipant.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

struct CompetitionParticipant {
    
    let person: Person
    let score: Int
    let rank: Double // value between 0...1

    var asJSON: [String : Any] {
        return ["person" : person.asJSON,
                "score" : score]
    }
}
