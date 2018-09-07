//
//  CompetitionCardRow.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import AlamofireImage

class CompetitionCardRow: UIView {
    
    struct Constants {
        static let maxOffset = CGFloat(100)
    }

    @IBOutlet weak var titleLabelOrNil: UILabel?
    @IBOutlet weak var imageViewOrNil: UIImageView? {
        didSet {
            imageViewOrNil?.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var rankBarOrNil: UIView?
    @IBOutlet weak var rankBarTrailingConstraintOrNil: NSLayoutConstraint?
    @IBOutlet weak var scoreLabelOrNil: UILabel?
    
    func display(_ participant: CompetitionParticipant) {
        titleLabelOrNil?.text = participant.person.name
        scoreLabelOrNil?.text = String(participant.score)
        let offset:CGFloat = participant.rank == 1 ? 0 : Constants.maxOffset * (1-participant.rank)
        rankBarTrailingConstraintOrNil?.constant = offset
//        imageViewOrNil?.setIm
    }
    
}
