//
//  OnboardingViewModel.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 7/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OnboardingViewModel {

    private(set) var title = BehaviorRelay(value: LocalizedStrings.OnboardingScreen.Title.default)
    private(set) var subtitle = BehaviorRelay(value: LocalizedStrings.OnboardingScreen.Subtitle.default)
    private(set) var loginButtonText = BehaviorRelay(value: LocalizedStrings.OnboardingScreen.LoginButton.default)
    
}
