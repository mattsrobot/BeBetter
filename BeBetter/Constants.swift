//
//  Constants.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

enum LocalizedStrings {
    
    enum FriendsListScreen {
        
        enum Title {
            static let `default` = NSLocalizedString("screen.friendslist.title.default")
        }
    }
}

fileprivate func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
