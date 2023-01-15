//
//  UIView+Extension.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/15.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview(_:))
    }
}
