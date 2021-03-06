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

class CompetitionListViewModel {
        
    fileprivate var connectivityClient: WatchConnectivityClient
    fileprivate var dataStore: Datastore
    fileprivate var disposeBag = DisposeBag()
    
    init(connectivityClient: WatchConnectivityClient = .shared, dataStore: Datastore = .shared) {
        self.connectivityClient = connectivityClient
        self.dataStore = dataStore
    }
    
    func competitions() -> Observable<[Competition]> {
        // Observe changes from the datastore
        return dataStore.competitions.asObservable()
    }

    func fetchCompetitions() {
        connectivityClient.fetchCompetitions()
    }
    
}
