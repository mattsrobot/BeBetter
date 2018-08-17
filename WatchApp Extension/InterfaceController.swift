//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by Matthew Wilkinson on 13/8/18.
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
        
        viewModel.fetchFriends().subscribe { event in
            if case let .next(friends) = event {
                self.table?.setNumberOfRows(friends.count, withRowType: "FriendRow")
                var i = 0
                repeat {
                    guard let row = self.table?.rowController(at: i) as? FriendRow else {
                        continue
                    }
                    let friend = friends[i]
                    row.nameLabel?.setText(friend.name)
                    row.distanceLabel?.setText("\(friend.distance)m")
                    i += 1
                } while (i < friends.count)
            }
        }.disposed(by: disposeBag)
    }
}


