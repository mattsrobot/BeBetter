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
    
    private(set) var title = BehaviorRelay(value: LocalizedStrings.FriendsListScreen.Title.default)

    fileprivate var competitionService: CompetitionService
    
    init(competitionService: CompetitionService = CompetitionService()) {
        self.competitionService = competitionService
    }
    
    func fetchCompetitions() -> Observable<[Person]> {
        return competitionService.fetchCompetitions()
    }
    
}
