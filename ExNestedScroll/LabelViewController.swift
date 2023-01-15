//
//  LabelViewController.swift
//  ExNestedScroll
//
//  Created by 김종권 on 2023/01/15.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class LabelViewController: UIViewController {
    // MARK: Constants
    private enum Metric {
    }
    
    // MARK: UIs
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .white
    }
    
    // MARK: Properties
    var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var id: String? {
        titleText
    }
    
    // MARK: Configures
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = randomColor
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
