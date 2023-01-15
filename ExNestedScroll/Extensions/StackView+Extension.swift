//
//  StackView+Extension.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/15.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach(addArrangedSubview(_:))
    }
}
