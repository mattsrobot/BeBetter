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

class InterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable?
    
    private let disposeBag = DisposeBag()
    
    private(set) var viewModel = FriendListViewModel()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        viewModel
            .fetchCompetitions()
            .subscribe { event in
                if case let .next(competition) = event {
                    self.display(competition)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func display(_ competition: [Competition]) {
//        self.table?.setNumberOfRows(friends.count, withRowType: "FriendRow")
//        for i in 0..<friends.count {
//            let friend = friends[i]
//            let row = self.table?.rowController(at: i) as? FriendRow
//            row?.nameLabel?.setText(friend.name)
////            row?.distanceLabel?.setText("\(friend.distance)m")
//        }
    }
}


