//
//  Theme.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct Theme {
    
    static let shared = Theme()
    
    var arcticWhite = BehaviorRelay(value: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    var blueyGrey = BehaviorRelay(value: #colorLiteral(red: 0.5215686275, green: 0.5882352941, blue: 0.7058823529, alpha: 1))
    var salesforceBlue = BehaviorRelay(value: #colorLiteral(red: 0.2039215686, green: 0.4980392157, blue: 0.862745098, alpha: 1))
    var deepBlue = BehaviorRelay(value: #colorLiteral(red: 0.09803921569, green: 0.1568627451, blue: 0.2784313725, alpha: 1))
    var midnightBlue = BehaviorRelay(value: #colorLiteral(red: 0.03921568627, green: 0.1019607843, blue: 0.2431372549, alpha: 1))
    
    func apply() {
        #if os(iOS)
            
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().barTintColor = midnightBlue.value
            
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : arcticWhite.value,
                                                                .font : UIFont(name: "ArialMT", size: 20)!]
            
            if #available(iOS 11.0, *) {
                UINavigationBar.appearance().prefersLargeTitles = true
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : arcticWhite.value,
                                                                    .font : UIFont(name: "ArialMT", size: 32)!]
            }
            
        #endif
    }
    
}
