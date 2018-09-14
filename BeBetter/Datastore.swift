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

    private(set) var competitions: BehaviorRelay<[Competition]> = BehaviorRelay(value: [])
}


/// A basic in-memory cache, won't scale with many large images.
class SimpleCache {
    
    static let shared = SimpleCache()
    
    var images = [String : UIImage]()
}
