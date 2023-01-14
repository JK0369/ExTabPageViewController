//
//  TabHeaderView.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/14.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

typealias UpdateHeaderItemType = (Int, HeaderItemType)

struct HeaderItemType {
    let title: String
    var isSelected: Bool
}

final class TabHeaderView: UIView {
    // MARK: Constants
    private enum Metric {
        static let interItemSpacing = 12.0
    }
    
    // MARK: UI
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = Metric.interItemSpacing
        }
    ).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = .zero
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.id)
    }
    
    // MARK: Properties
    fileprivate var items = [HeaderItemType]()
    fileprivate let disposeBag = DisposeBag()
    fileprivate let selectedPublish = PublishSubject<Int>()
    
    // MARK: Initializers
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init() has not been implemented")
    }
    
    // MARK: Layout
    private func setUp() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.dataSource = self
    }
}

extension TabHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.id, for: indexPath) as? HeaderCell
        else { return UICollectionViewCell() }
        
        Observable
            .just(items[indexPath.item])
            .bind(to: cell.rx.prepare)
            .disposed(by: cell.disposeBag)
        
        cell.rx.tapContent
            .mapTo(indexPath.item)
            .bind(to: selectedPublish.asObserver())
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}

extension Reactive where Base: TabHeaderView {
    var selectedIndex: Observable<Int> {
        base.selectedPublish.asObservable()
    }
    
    var updateCells: Binder<[UpdateHeaderItemType]> {
        Binder(base) { base, items in
            
            items.forEach { ind, item in
                base.items[ind] = item
            }
            let indexPaths = items.map { ind, item in IndexPath(item: ind, section: 0) }
            UIView.performWithoutAnimation {
                base.collectionView.reloadItems(at: indexPaths)
            }
        }
    }
    
    var items: Binder<[HeaderItemType]> {
        Binder(base) { base, items in
            base.items = items
        }
    }
}
