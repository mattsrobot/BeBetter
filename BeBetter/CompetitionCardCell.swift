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

class CompetitionCardCell: UITableViewCell {

    @IBOutlet weak var cardViewOrNil: UIView? {
        didSet {
            cardViewOrNil?.layer.cornerRadius = 8
        }
    }
    
    fileprivate var disposeBag = DisposeBag()
    
    func display(_ person: Person, for theme: Theme) {
        
        guard let cardView = cardViewOrNil else {
            return
        }
        
        theme.midnightBlue
            .bind(to: rx.backgroundColor)
            .disposed(by: disposeBag)
        
        theme.deepBlue
            .bind(to: cardView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}
