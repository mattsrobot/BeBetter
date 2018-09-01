//
//  Constants.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

enum LocalizedStrings {
    
    enum CompetitionListScreen {
        
        enum Title {
            static let `default` = NSLocalizedString("screen.competitionlist.title.default")
        }
        
        enum Categories {
            static let runningDistance = NSLocalizedString("screen.competitionlist.categories.runningdistance")
            static let stepCount = NSLocalizedString("screen.competitionlist.categories.setepcount")
            static let energyBurned = NSLocalizedString("screen.competitionlist.categories.energyburned")
        }
        
    }
}

fileprivate func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
