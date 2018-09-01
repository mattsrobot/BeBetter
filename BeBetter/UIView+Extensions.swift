//
//  UIView+Extensions.swift
//  BeBetter
//
//  Created by Matthew Wilkinson on 1/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

#if os(iOS) || os(tvOS)
    
    import RxCocoa
    import RxSwift
    
    extension Reactive where Base: UIView {
        public var backgroundColor: Binder<UIColor?> {
            return Binder(self.base) { view, color in
                view.backgroundColor = color
            }
        }
    }
    
#endif
