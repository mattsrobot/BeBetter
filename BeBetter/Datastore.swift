//
//  Datastore.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 18/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class Datastore {
    
    static let shared = Datastore()

    private(set) var friends: BehaviorRelay<[Person]> = BehaviorRelay(value: [])
}
