//
//  CompetitionCardRow.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SalesforceSDKCore

class CompetitionCardRow: UIView {
    
    struct Constants {
        static let maxOffset = CGFloat(150)
    }

    var service = CompetitionService()
    
    @IBOutlet weak var titleLabelOrNil: UILabel?
    @IBOutlet weak var imageViewOrNil: UIImageView? {
        didSet {
            imageViewOrNil?.layer.cornerRadius = 16
            imageViewOrNil?.layer.masksToBounds = true
            imageViewOrNil?.image = SFSDKResourceUtils.imageNamed("profile-placeholder")
        }
    }
    @IBOutlet weak var rankBarOrNil: UIView?
    @IBOutlet weak var rankBarTrailingConstraintOrNil: NSLayoutConstraint?
    @IBOutlet weak var scoreLabelOrNil: UILabel?
    
    func display(_ participant: CompetitionParticipant) {
        
        titleLabelOrNil?.text = participant.person.name
        scoreLabelOrNil?.text = String(participant.score)
        
        let offset: CGFloat = participant.rank == 1 ? 0 : Constants.maxOffset * (1-participant.rank)

        rankBarTrailingConstraintOrNil?.constant = offset
        
        guard let imageView = imageViewOrNil, let photoURL = participant.person.photoURL else {
            imageViewOrNil?.image = SFSDKResourceUtils.imageNamed("profile-placeholder")
            return
        }
        
        service.fetchProfileImage(photoURL: photoURL) { (image) in
            imageView.image = image
        }
    }
    
}
