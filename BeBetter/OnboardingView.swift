//
//  OnboardingView.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 7/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SalesforceSDKCore
import SalesforceSwiftSDK

class OnboardingView: UIViewController {

    @IBOutlet weak var loginButtonOrNil: UIButton?
    
    fileprivate var disposeBag = DisposeBag()
    
    private(set) var viewModel: OnboardingViewModel!
    private(set) var theme: Theme!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(with viewModel: OnboardingViewModel, theme: Theme = .shared) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.theme = theme
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("use init(with viewModel: theme:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(with viewModel: theme:)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }
    
    fileprivate func bind(to viewModel: OnboardingViewModel) {
        
        guard let loginButton = loginButtonOrNil else {
            return
        }
        
        viewModel.loginButtonText
            .bind(to: loginButton.rx.title())
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { _ in
                SalesforceSwiftSDKManager.shared().launch()
            })
            .disposed(by: disposeBag)
    }
    
}
