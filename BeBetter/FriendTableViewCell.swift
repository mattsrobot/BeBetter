//
//  FriendTableViewCell.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var distanceLabel: UILabel?
    
    func display(_ person: Person) {
        nameLabel?.text = person.name
        distanceLabel?.text = "\(person.distance)m"
    }
}
