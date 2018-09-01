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
    
    init(name: String) {
        self.name = name
    }

    init(json: JSON) {
        self.name = json["name"].string ?? ""
    }
    
    var asJSON: [String : Any] {
        return ["name" : name]
    }
    
}
