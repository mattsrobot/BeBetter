//
//  UIView+Extensions.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIView {
    public var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.backgroundColor = color
        }
    }
}

extension UIView {
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
