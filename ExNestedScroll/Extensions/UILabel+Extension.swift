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
        let size = (self as NSString).size(withAttributes: [.font: font])
        let buffer = 0.2 // 이게 없으면 UILabel이 잘려보이는 현상이 존재
        return CGSize(width: size.width + buffer, height: size.height)
    }
}
