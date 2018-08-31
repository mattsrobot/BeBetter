//
//  FriendListViewModel.swift
//  WatchApp Extension
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import WatchKit
import WatchConnectivity
import RxCocoa
import RxSwift

class FriendListViewModel {
    
    fileprivate var connectivityClient: WatchConnectivityClient
    fileprivate var dataStore: Datastore
    
    init(connectivityClient: WatchConnectivityClient = .shared, dataStore: Datastore = .shared) {
        self.connectivityClient = connectivityClient
        self.dataStore = dataStore
    }

    func fetchFriends() -> Observable<[Person]> {
        // As the watch/ios connection to fetch latest friends
        connectivityClient.fetchFriends()
        // Observe changes from the datastore
        return dataStore.friends.asObservable()
    }
    
    
}
