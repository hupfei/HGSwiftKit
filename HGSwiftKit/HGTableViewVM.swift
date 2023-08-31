//
//  HGTableViewVM.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class HGTableViewVM: BaseViewModel {
    /// 页码
    open var pageNo: Int = 1
    /// 每一页大小
    open var pageSize: Int { 20 }
    /// 样式
    open var tableViewStyle: UITableView.Style { .plain }
    /// 是否可以下拉刷新
    open var hasHeaderRefresh: Bool { false }
    /// 是否可以上拉加载
    open var hasFooterRefresh: Bool { false }
    /// cell圆角值
    open var cellCornerRadius: CGFloat { 0 }
    /// 数据请求结果，成功时返回的是数据总数
    public let requestResult = BehaviorRelay<Result<Int, Error>>(value: .success(0))
    /// 空白文字
    open var emptyTitle: String { "暂无信息" }
    /// 空白图片
    open var emptyImage: UIImage? { UIImage(named: "hg_empty_default") }
    /// viewDidLoad 后请求数据
    open var shouldRequestDataAfterViewDidLoad: Bool { true }
}
