//
//  MyCell.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/14.
//

import UIKit
import SnapKit
import RxSwift
import Then

final class MyCell: UICollectionViewCell {
    // MARK: Constants
    static let id = "MyCell"
    
    // MARK: Properties
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        prepare(color: nil)
    }
    
    func prepare(color: UIColor?) {
        backgroundColor = color
    }
}

