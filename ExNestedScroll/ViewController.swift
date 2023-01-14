//
//  ViewController.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/14.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxSwiftExt

class ViewController: UIViewController {
    // MARK: Constants
    private enum Metric {
        static let headerHeight = 56.0
        static let headerViewHorizontalInset = 12.0
    }
    
    // MARK: UI
    private let tabHeaderView = TabHeaderView()
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        bind()
    }
    
    private func setUp() {
        view.addSubview(tabHeaderView)
        
        tabHeaderView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview().inset(Metric.headerViewHorizontalInset)
            $0.height.equalTo(Metric.headerHeight)
        }
    }
    
    private func bind() {
        var items = (0...7)
            .map(String.init)
            .enumerated()
            .map { index, str in HeaderItemType(title: str, isSelected: index == 0) }
        
        Observable
            .just(items)
            .bind(to: tabHeaderView.rx.items)
            .disposed(by: disposeBag)
        
        tabHeaderView.rx.selectedIndex
            .observe(on: MainScheduler.instance)
            .bind(with: self) { ss, newSelectedIndex in
                let lastSelectedIndex = items.firstIndex(where: { $0.isSelected })
                guard let lastSelectedIndex, newSelectedIndex != lastSelectedIndex else { return }
                
                items[lastSelectedIndex].isSelected = false
                items[newSelectedIndex].isSelected = true
                
                let updateHeaderItemTypes = [
                    UpdateHeaderItemType(lastSelectedIndex, items[lastSelectedIndex]),
                    UpdateHeaderItemType(newSelectedIndex, items[newSelectedIndex])
                ]
                
                Observable
                    .just(updateHeaderItemTypes)
                    .take(1)
                    .filter { !$0.isEmpty }
                    .bind(to: ss.tabHeaderView.rx.updateCells)
                    .disposed(by: ss.disposeBag)
            }
            .disposed(by: disposeBag)
    }
}
