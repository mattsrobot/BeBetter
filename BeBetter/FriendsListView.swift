//
//  FriendsListView.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FriendsListView: UIViewController {
    
    fileprivate struct Identifiers {
        static let friendsList = "FriendTableViewCell"
    }
    
    private(set) var viewModel: FriendsListViewModel!
    fileprivate var disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            let friendsTableViewCellNib = UINib.init(nibName: Identifiers.friendsList, bundle: .main)
            tableView?.register(friendsTableViewCellNib, forCellReuseIdentifier: Identifiers.friendsList)
        }
    }
    
    init(with viewModel: FriendsListViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("use init(with viewModel:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(with viewModel:)")
    }
    
    fileprivate func bind(to viewModel: FriendsListViewModel) {
        guard let tableView = tableView else {
            return
        }
        
        viewModel.fetchFriends()
            .bind(to: tableView.rx.items(cellIdentifier: Identifiers.friendsList)) { (index, friend: Person, cell: FriendTableViewCell) in
                cell.display(friend)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }

}
