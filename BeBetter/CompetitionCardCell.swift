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
import SnapKit

class CompetitionCardCell: UITableViewCell {

    @IBOutlet weak var cardViewOrNil: UIView? {
        didSet {
            cardViewOrNil?.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var competitionTitleLabelOrNil: UILabel?
    @IBOutlet weak var stackViewOrNil: UIStackView?
    
    fileprivate var disposeBag = DisposeBag()
    
    func display(_ competition: Competition, for theme: Theme) {
        
        guard let cardView = cardViewOrNil, let competitionTitleLabel = competitionTitleLabelOrNil, let stackView = stackViewOrNil else {
            return
        }
        
        stackView.subviews.forEach { $0.removeFromSuperview() }
        
        competitionTitleLabel.text = competition.name
        
        competition
            .participants
            .sorted(by: { $0.rank > $1.rank })
            .map({ participant in
                let row: CompetitionCardRow = CompetitionCardRow.fromNib()
                row.titleLabelOrNil?.text = participant.person.name
                return row
            })
            .forEach({ row in
                stackView.addArrangedSubview(row)
            })
        
        theme.midnightBlue
            .bind(to: rx.backgroundColor)
            .disposed(by: disposeBag)
        
        theme.deepBlue
            .bind(to: cardView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}
