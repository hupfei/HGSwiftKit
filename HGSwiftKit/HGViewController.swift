//
//  HGViewController.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx
import UIKit

open class HGViewController: UIViewController {
    
    open var viewModel: BaseViewModel?
    
    open lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.spacing = 0
        view.axis = .vertical
        view.backgroundColor = .clear
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return view
    }()
    
    public init(viewModel: BaseViewModel? = BaseViewModel()) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, viewModel: BaseViewModel? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewModel = viewModel
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindViewModel()
    }
    
    open func makeUI() {
        
    }
    
    open func bindViewModel() {
        
    }
}
