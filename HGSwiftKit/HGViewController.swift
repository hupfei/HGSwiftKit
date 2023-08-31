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
    
    open lazy var backBarButton: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.title = ""
        return btn
    }()
    
    open lazy var closeBarButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(image: UIImage(named: "hg_navigation_back"),
                                   style: .plain,
                                   target: self,
                                   action: nil)
        btn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.closeBarButtonAction()
        }).disposed(by: rx.disposeBag)
        return btn
    }()
    
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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        adjustLeftBarButtonItem()
    }
    
    open func makeUI() {
        
    }
    
    open func bindViewModel() {
        
    }
    
    open func closeBarButtonAction() {
        self.dismiss(animated: true)
    }
    
    private func adjustLeftBarButtonItem() {
        if #available(iOS 14.0, *) {
            navigationItem.backButtonDisplayMode = .minimal
        } else {
            navigationItem.backBarButtonItem = backBarButton
        }
        
        if let count = navigationController?.viewControllers.count, count == 1,  self.presentingViewController != nil {
            // presented
            self.navigationItem.leftBarButtonItem = closeBarButton
        }
    }
}
