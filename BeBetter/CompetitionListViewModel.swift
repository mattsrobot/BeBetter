//
//  FriendsListViewModel.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CompetitionListViewModel {
    
    private(set) var title = BehaviorRelay(value: LocalizedStrings.CompetitionListScreen.Title.default)

    fileprivate var competitionService: CompetitionService
    fileprivate var dataStore: Datastore
    
    init(competitionService: CompetitionService = CompetitionService(), dataStore: Datastore = .shared) {
        self.competitionService = competitionService
        self.dataStore = dataStore
    }
    
    func fetchCompetitions() -> Observable<[Competition]> {
        competitionService.fetchCompetitions()
        return dataStore.competitions.asObservable()
    }
    
}
