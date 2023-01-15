//
//  ContentsView.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/15.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

typealias UpdateContentsItemType = (String?, UIColor?)

final class ContentsView: UIView {
    // MARK: Constants
    private enum Metric {
        static let itemWidth = UIScreen.main.bounds.width
        static let itemSize = CGSize(width: itemWidth, height: itemWidth * 1.2)
    }
    
    // MARK: UI
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = 0
            $0.minimumLineSpacing = 0
            $0.itemSize = Metric.itemSize
        }
    ).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = .zero
        $0.backgroundColor = .clear
        $0.isPagingEnabled = true
        $0.clipsToBounds = true
        $0.register(MyCell.self, forCellWithReuseIdentifier: MyCell.id)
    }
    
    // MARK: Properties
    fileprivate var items = [UpdateContentsItemType]()
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: Initializers
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init() has not been implemented")
    }
    
    private func setUp() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.dataSource = self
    }
}

extension ContentsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.id, for: indexPath) as? MyCell
        else { return UICollectionViewCell() }
        
        Observable
            .just(items[indexPath.item])
            .bind(to: cell.rx.prepare)
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}
