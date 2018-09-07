//
//  Constants.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

enum Secrets {
    static let remoteAccessConsumerKey = "3MVG9fTLmJ60pJ5IhfNYyIyo783baljqJytKsewb1gjhN9i.YfI0yNISwpiTuM63dds267dC3GSSzpug2MS.e"
    static let OAuthRedirectURI        = "testsfdc:///mobilesdk/detect/oauth/done"
}

enum LocalizedStrings {
    
    enum OnboardingScreen {
        
        enum LoginButton {
            static let `default` = NSLocalizedString("screen.onboarding.loginButton.default")
        }
        
        enum Title {
            static let `default` = NSLocalizedString("screen.onboarding.title.default")
        }
        
        enum Subtitle {
            static let `default` = NSLocalizedString("screen.onboarding.subtitle.default")
        }
    }
    
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
