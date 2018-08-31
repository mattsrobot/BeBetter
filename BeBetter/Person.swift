//
//  Person.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Person {

    let name: String
    let distance: Int
    
    init(name: String, distance: Int) {
        self.name = name
        self.distance = distance
    }

    init(json: JSON) {
        self.name = json["name"].string ?? ""
        self.distance = json["distance"].int ?? 0
    }
    
    var asJSON: [String : Any] {
        return ["name" : name, "distance" : distance]
    }
    
}
