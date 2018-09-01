//
//  FriendTableViewCell.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var distanceLabel: UILabel?
    
    fileprivate var disposeBag = DisposeBag()
    
    func display(_ person: Person, for theme: Theme) {
        nameLabel?.text = person.name
        distanceLabel?.text = "\(person.distance)m"
        
        theme.midnightBlue
            .bind(to: rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}
