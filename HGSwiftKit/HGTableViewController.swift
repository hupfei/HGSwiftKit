//
//  HGTableViewController.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SwifterSwift
import DZNEmptyDataSet
import MJRefresh
import UIKit

class HGTableViewController: HGViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: (viewModel as! HGTableViewVM).tableViewStyle)
        view.configTableView()
        view.register(cellWithClass: HGTableViewCell.self)
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    let headerRefreshTrigger = PublishRelay<Void>()
    let footerRefreshTrigger = PublishRelay<Void>()
    
    override func makeUI() {
        super.makeUI()
        
        stackView.addArrangedSubview(tableView)
        
        guard let viewModel = viewModel as? HGTableViewVM else { return }
        
        if viewModel.hasHeaderRefresh {
            let header = MJRefreshNormalHeader.init {
                [weak self] in
                guard let ss = self else { return }
                viewModel.pageNo = 1
                if viewModel.hasFooterRefresh {
                    ss.tableView.mj_footer?.isHidden = false
                }
                ss.headerRefreshTrigger.accept(())
            }
            header.lastUpdatedTimeLabel?.isHidden = true
            header.stateLabel?.textColor = .black
            header.setTitle("下拉刷新", for: .idle)
            tableView.mj_header = header
            
            if viewModel.shouldRequestDataAfterViewDidLoad {
                tableView.mj_header?.beginRefreshing()
            }
        }
        
        if viewModel.hasFooterRefresh {
            let footer = MJRefreshBackNormalFooter.init {
                [weak self] in
                guard let ss = self else { return }
                viewModel.pageNo += 1
                ss.footerRefreshTrigger.accept(())
            }
            footer.setTitle("已经到底啦", for: .noMoreData)
            footer.stateLabel?.textColor = UIColor(hexString: "#707070")
            footer.stateLabel?.font = .systemFont(ofSize: 12)
            tableView.mj_footer = footer
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? HGTableViewVM else { return }

        viewModel.requestResult.subscribe(onNext: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let count):
                self.updateRefreshState(totalCount: count)
            case .failure:
                if let isRefreshing = self.tableView.mj_header?.isRefreshing, isRefreshing {
                    self.tableView.mj_header?.endRefreshing()
                }
                if let isRefreshing = self.tableView.mj_footer?.isRefreshing, isRefreshing {
                    viewModel.pageNo -= 1
                    self.tableView.mj_footer?.endRefreshing()
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    private func updateRefreshState(totalCount: Int) {
        guard let viewModel = viewModel as? HGTableViewVM else { return }
        if let isRefreshing = tableView.mj_header?.isRefreshing, isRefreshing {
            tableView.mj_header?.endRefreshing()
            if tableView.mj_footer?.state == .noMoreData {
                tableView.mj_footer?.resetNoMoreData()
            }
            if totalCount < viewModel.pageSize {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
        
        if let isRefreshing = tableView.mj_footer?.isRefreshing, isRefreshing {
            if viewModel.pageNo * viewModel.pageSize == totalCount {
                tableView.mj_footer?.endRefreshing()
            } else {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel as? HGTableViewVM else { return }
        tableView.hg_configureCellForDisplay(cell, forRowAt: indexPath, withCornerRadius: viewModel.cellCornerRadius)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HGTableViewCell.self, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
    
    // MARK: - DZNEmptyDataSet
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return (viewModel as! HGTableViewVM).emptyImage
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: (viewModel as! HGTableViewVM).emptyTitle, attributes: [.font: UIFont.systemFont(ofSize: 25), .foregroundColor: UIColor(hexString: "D5D5D5")!])
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        switch (viewModel as! HGTableViewVM).requestResult.value {
        case .success(let count):
            return count == 0
        case .failure:
            return true
        }
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
}
