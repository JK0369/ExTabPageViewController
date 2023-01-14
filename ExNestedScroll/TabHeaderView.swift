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
    fileprivate enum Metric {
        static let interItemSpacing = 12.0
        static let underlineViewHeight = 4.0
        static let underlineViewTopSpacing = 6.0
        static let collectionViewBottomSpacing = underlineViewHeight + underlineViewTopSpacing
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
    fileprivate let underlineView = UIView().then {
        $0.backgroundColor = .gray
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
        addSubview(underlineView)
        
        collectionView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(Metric.collectionViewBottomSpacing)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        
        DispatchQueue.main.async {
            self.selectedPublish.onNext(0)
        }
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

extension TabHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = items[indexPath.row].title.size(OfFont: .systemFont(ofSize: 18))
        let width = size.width + 0.2
        return CGSize(width: width, height: size.height)
    }
}

extension Reactive where Base: TabHeaderView {
    var selectedIndex: Observable<Int> {
        base.selectedPublish.asObservable()
            .do { ind in
                let selectedCell = base.collectionView.cellForItem(at: IndexPath(item: ind, section: 0))
                guard let selectedCell else { return }
                base.underlineView.snp.remakeConstraints {
                    $0.left.right.equalTo(selectedCell)
                    $0.bottom.equalTo(selectedCell).offset(TabHeaderView.Metric.underlineViewTopSpacing)
                    $0.height.equalTo(TabHeaderView.Metric.underlineViewHeight)
                }
                UIView.animate(withDuration: 0.1, delay: 0, animations: base.layoutIfNeeded)
            }
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
