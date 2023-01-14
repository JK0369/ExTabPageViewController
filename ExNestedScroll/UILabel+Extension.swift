//
//  UILabel+Extension.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/14.
//

import Foundation
import UIKit

extension String {
    func size(OfFont font: UIFont) -> CGSize {
        (self as NSString).size(withAttributes: [.font: font])
    }
}
