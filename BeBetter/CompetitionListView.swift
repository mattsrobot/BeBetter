//
//  FriendsListView.swift
//  BeBetter
//
//  Created by Radoslava Radkova & Matthew Wilkinson on 13/8/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CompetitionListView: UIViewController {
    
    fileprivate struct Identifiers {
        static let cardList = "CompetitionCardCell"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private(set) var viewModel: CompetitionListViewModel!
    private(set) var theme: Theme!
    
    fileprivate var disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            let friendsTableViewCellNib = UINib.init(nibName: Identifiers.cardList, bundle: .main)
            tableView?.register(friendsTableViewCellNib, forCellReuseIdentifier: Identifiers.cardList)
        }
    }
    
    init(with viewModel: CompetitionListViewModel, theme: Theme = .shared) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.theme = theme
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("use init(with viewModel:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(with viewModel:)")
    }
    
    fileprivate func bind(to viewModel: CompetitionListViewModel) {
        
        guard let tableView = tableView else {
            return
        }
        
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.fetchCompetitions()
            .bind(to: tableView.rx.items(cellIdentifier: Identifiers.cardList)) { (index, competition: Competition, cell: CompetitionCardCell) in
                cell.display(competition, for: self.theme)
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func apply(_ theme: Theme) {
        
        guard let tableView = tableView else {
            return
        }
        
        theme.midnightBlue
            .bind(to: view.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        theme.midnightBlue
            .bind(to: tableView.rx.backgroundColor)
            .disposed(by: disposeBag)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        apply(theme)
    }

}
