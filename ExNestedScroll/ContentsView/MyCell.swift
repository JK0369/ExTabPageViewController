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
    
    // MARK: UI
    fileprivate let titleLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 40, weight: .regular)
        $0.textColor = .white
    }
    
    // MARK: Properties
    private(set) var disposeBag = DisposeBag()
    
    // MARK: Initializers
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.leading.greaterThanOrEqualToSuperview()
            $0.bottom.right.lessThanOrEqualToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        rx.prepare.onNext(nil)
    }
}

extension Reactive where Base: MyCell {
    var prepare: Binder<UpdateContentsItemType?> {
        Binder(base) { base, item in
            base.titleLabel.text = item?.0
            base.backgroundColor = item?.1
        }
    }
}
