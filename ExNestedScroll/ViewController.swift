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
        static let horizontalInset = 20.0
        static let pageHeight = UIScreen.main.bounds.width * 1.3
    }
    
    // MARK: UI
    private let tabHeaderView = TabHeaderView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
    }
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private var items = ["1", "jake", "iOS 앱 개발 알아가기", "2", "jake123"]
        .enumerated()
        .map { index, str in HeaderItemType(title: str, isSelected: index == 0) }
    private var lastSelectedIndex: Int {
        items.firstIndex(where: { $0.isSelected }) ?? 0
    }
    fileprivate var contentViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers()
        setUpViews()
        setUpLayouts()
        bindTabHeader()
    }
    
    private func setViewControllers() {
        items
            .map(\.title)
            .forEach { title in
                let vc = LabelViewController()
                vc.titleText = title
                contentViewControllers.append(vc)
            }
    }
    
    private func setUpViews() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        pageViewController.setViewControllers([contentViewControllers[0]], direction: .forward, animated: false)
    }
    
    private func setUpLayouts() {
        view.addSubviews(
            tabHeaderView,
            scrollView
        )
        scrollView.addSubviews(
            stackView
        )
        stackView.addArrangedSubviews(
            pageViewController.view
        )
        
        tabHeaderView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview().inset(Metric.headerViewHorizontalInset)
            $0.height.equalTo(Metric.headerHeight)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(tabHeaderView.snp.bottom)
            $0.left.right.equalToSuperview().inset(Metric.horizontalInset)
            $0.bottom.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        // height 지정 필수
        pageViewController.view.snp.makeConstraints {
            $0.height.equalTo(Metric.pageHeight)
        }
    }
    
    private func bindTabHeader() {
        Observable
            .just(items)
            .bind(to: tabHeaderView.rx.setItems)
            .disposed(by: disposeBag)
        
        tabHeaderView.rx.onIndexSelected
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { ss, newSelectedIndex in
                ss.updatePageView(newSelectedIndex)
                ss.updateTapHeaderCell(newSelectedIndex)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateTapHeaderCell(_ index: Int) {
        let lastSelectedIndex = lastSelectedIndex
        guard index != lastSelectedIndex else { return }
        
        items[lastSelectedIndex].isSelected = false
        items[index].isSelected = true
        
        let updateHeaderItemTypes = [
            UpdateHeaderItemType(lastSelectedIndex, items[lastSelectedIndex]),
            UpdateHeaderItemType(index, items[index])
        ]

        tabHeaderView.rx.updateUnderline.onNext(index)
        
        Observable
            .just(updateHeaderItemTypes)
            .take(1)
            .filter { !$0.isEmpty }
            .bind(to: tabHeaderView.rx.updateCells)
            .disposed(by: disposeBag)
    }
    
    private func updatePageView(_ index: Int) {
        let viewController = contentViewControllers[index]
        let direction = lastSelectedIndex < index ? UIPageViewController.NavigationDirection.forward : .reverse
        pageViewController.setViewControllers([viewController], direction: direction, animated: true)
    }
}

extension ViewController: UIPageViewControllerDataSource {
    // left -> right 스와이프 하기 직전 호출 (다음 화면은 무엇인지 리턴)
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = contentViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return contentViewControllers[previousIndex]
    }
    
    // right -> left 스와이프 하기 직전 호출 (이전 화면은 무엇인지 리턴)
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = contentViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < contentViewControllers.count else { return nil }
        return contentViewControllers[nextIndex]
    }
}

extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else { return }
        updateTabIndex()
    }
    
    private func updateTabIndex() {
        guard
            let vc = (pageViewController.viewControllers?.first as? LabelViewController),
            let id = vc.id,
            let currentIndex = items.firstIndex(where: { id == $0.title })
        else { return }
        
        updateTapHeaderCell(currentIndex)
    }
}

var randomColor: UIColor {
    UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
}
