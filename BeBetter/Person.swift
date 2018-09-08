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
    let photoURL: URL?
    
    init(name: String, photoURL: URL?) {
        self.name = name
        self.photoURL = photoURL
    }

    init(json: JSON) {
        self.name = json["name"].string ?? ""
        self.photoURL = json["photoURL"].url
    }
    
    var asJSON: [String : Any?] {
        return ["name" : name,
                "photoURL" : photoURL]
    }
    
}
