//
//  FriendListViewModel.swift
//  WatchApp Extension
//
//  Created by Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import WatchKit
import WatchConnectivity
import RxCocoa
import RxSwift

class FriendListViewModel {
    
    fileprivate var connectivityClient: WatchConnectivityClient
    
    init(connectivityClient: WatchConnectivityClient = WatchConnectivityClient()) {
        self.connectivityClient = connectivityClient
    }

    func fetchFriends() -> Observable<[Person]> {
        return connectivityClient.friends.asObservable()
    }
    
    
}
