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
    private(set) var isRefreshing = BehaviorRelay(value: false)

    fileprivate var competitionService: CompetitionService
    fileprivate var dataStore: Datastore
    fileprivate var disposeBag = DisposeBag()
    
    init(competitionService: CompetitionService = CompetitionService(), dataStore: Datastore = .shared) {
        self.competitionService = competitionService
        self.dataStore = dataStore
    }
    
    func fetchCompetitions() {
        
        if isRefreshing.value {
            return
        }
        
        isRefreshing.accept(true)
        
        competitionService
            .fetchCompetitions()
            .bind { _ in
                self.isRefreshing.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    func competitions() -> Observable<[Competition]> {
        return dataStore.competitions.asObservable()
    }
    
}
