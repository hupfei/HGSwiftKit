//
//  HGTableViewCell.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import UIKit
import SwifterSwift

open class HGTableViewCell: UITableViewCell {
    /// cell 水平缩进
    var horizontalInset: CGFloat { 0 }
    var verticalInset: CGFloat { 0 }
    /// 是否显示分隔线
    var shouldShowSeparator: Bool { false }
    /// cell 的分隔线位置
    var cellSeparatorInsets: UIEdgeInsets { UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) }
    /// 分隔线颜色
    var cellSeparatorColor: UIColor? { UIColor(hexString: "E9E9E9") }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        didInitialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialize()
    }
    
    /// 重写 frame 以达到 insetGrouped 效果
    public override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += horizontalInset
            newFrame.origin.y += verticalInset
            newFrame.size.width -= horizontalInset * 2
            newFrame.size.height -= verticalInset * 2
            super.frame = newFrame
        }
    }
    
    func didInitialize() {
        accessoryType = .none
        backgroundColor = .white
        
        if shouldShowSeparator {
            self.contentView.layer.addSublayer(topSeparatorLayer)
            self.contentView.layer.addSublayer(separatorLayer)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if shouldShowSeparator, let indexPath = cellIndexPath {
            topSeparatorLayer.isHidden = indexPath.row != 0
            topSeparatorLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: kLineHeight)
            
            if let _tableView = tableView, let numberOfRowsInsection = _tableView.dataSource?.tableView(_tableView, numberOfRowsInSection: indexPath.section) {
                if indexPath.row == numberOfRowsInsection - 1 {
                    // 最后一行的cell
                    separatorLayer.frame = CGRect(x: 0, y: bounds.height - kLineHeight + cellSeparatorInsets.top - cellSeparatorInsets.bottom, width: bounds.width, height: kLineHeight)
                } else {
                    separatorLayer.frame = CGRect(x: cellSeparatorInsets.left, y: bounds.height - kLineHeight + cellSeparatorInsets.top - cellSeparatorInsets.bottom, width: bounds.width - cellSeparatorInsets.left - cellSeparatorInsets.right, height: kLineHeight)
                }
            }
        }
    }
    
//    func bind(to viewModel: HGTableViewVM, at indexPath: IndexPath) {
//        self.viewModel = viewModel
//    }
    
    // MARK: - private lazy var
    
    private lazy var separatorLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = cellSeparatorColor?.cgColor
        return layer
    }()
    
    private lazy var topSeparatorLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = cellSeparatorColor?.cgColor
        return layer
    }()
    
    private var tableView: UITableView? {
        return self.value(forKey: "_tableView") as? UITableView
    }
}

private var kAssociatedKey_cellIndexPath: Void?
public extension UITableViewCell {
    
    /// cell 所在的 indexPath
    var cellIndexPath: IndexPath? {
        set {
            objc_setAssociatedObject(self, &kAssociatedKey_cellIndexPath, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let value = objc_getAssociatedObject(self, &kAssociatedKey_cellIndexPath) as? IndexPath
            guard let _value = value else {
                return nil
            }
            return _value
        }
    }
}
