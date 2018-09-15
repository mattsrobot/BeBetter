//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import WatchKit
import Foundation
import RxSwift

class CompetitionListView: WKInterfaceController {
    
    var client = WatchConnectivityClient.shared
    
    @IBOutlet var tableOrNil: WKInterfaceTable?
    
    fileprivate let disposeBag = DisposeBag()
    
    private(set) var viewModel = CompetitionListViewModel()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        viewModel
            .competitions()
            .subscribe { event in
                if case let .next(competitions) = event {
                    self.display(competitions)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.fetchCompetitions()
    }
    
    private func display(_ competitions: [Competition]) {
        
        if let rows = tableOrNil?.numberOfRows, rows > 0 {
            tableOrNil?.removeRows(at: IndexSet(0...rows))
        }
        
        var index = 0
        for competition in competitions {
            
            tableOrNil?.insertRows(at: IndexSet(integer: index), withRowType: "CompetitionRow")
            let row = tableOrNil?.rowController(at: index) as? CompetitionRow
            row?.nameLabelOrNil?.setText(competition.name)
            index += 1
            
            for participant in competition.participants.sorted(by: { $0.rank > $1.rank }) {
                
                tableOrNil?.insertRows(at: IndexSet(integer: index), withRowType: "ParticipantRow")
                let profileRow = tableOrNil?.rowController(at: index) as? ParticipantRow
                profileRow?.nameLabelOrNil?.setText(participant.person.name)
                profileRow?.separatorOrNil?.setWidth(100 * participant.rank)
                index += 1
                
                guard let photoURL = participant.person.photoURL else {
                    continue
                }
                
                client.fetchProfileImage(profileURL: photoURL.absoluteString, replyHandler: { image in
                    profileRow?.profileImageOrNil?.setImage(image)
                })
                
            }
        }
    }
}


