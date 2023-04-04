//
//  UITableView+Extensions.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit

public extension UITableView {
        
    /// 统一渲染tableView外观
    /// - Parameter estimatedHeightEnabled: 是否预测高度，默认为 true
    func configTableView(estimatedHeightEnabled: Bool = true) {
        // 设置高度
        if (estimatedHeightEnabled) {
            estimatedRowHeight = 45
            rowHeight = UITableView.automaticDimension
        } else {
            estimatedRowHeight = 0
            rowHeight = 45
        }
        estimatedSectionHeaderHeight = 0
        sectionHeaderHeight = CGFloat.leastNormalMagnitude
        estimatedSectionFooterHeight = 0
        sectionFooterHeight = CGFloat.leastNormalMagnitude
        
        backgroundColor = .white
        separatorStyle = .none
        keyboardDismissMode = .onDrag

        // 去掉空白的cell
        if (style == .plain) {
            tableFooterView = UIView()
        }
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
    }
}

private var kAssociatedKey_selectedBackgroundColor: Void?
private var kAssociatedKey_shadowInfo: Void?
public extension UITableView {
        
    ///阴影参数
    var shadowInfo: ShadowInfo? {
        set { objc_setAssociatedObject(self, &kAssociatedKey_shadowInfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &kAssociatedKey_shadowInfo) as? ShadowInfo }
    }
    
    ///点击时的背景色
    var selectedBackgroundColor: UIColor? {
        set { objc_setAssociatedObject(self, &kAssociatedKey_selectedBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &kAssociatedKey_selectedBackgroundColor) as? UIColor }
    }
    
    /// 为第一行和最后一行的cell添加圆角
    /// 为所有行添加点击效果
    /// @note 在  tableView(_:willDisplay:forRowAt:) 中调用

    func hg_configureCellForDisplay(_ cell: UITableViewCell, forRowAt indexPath: IndexPath, withCornerRadius radius: CGFloat = 0) {
        cell.cellIndexPath = indexPath
        if radius <= 0 {
            return
        }
        
        let numberOfRowsInsection = dataSource?.tableView(self, numberOfRowsInSection: indexPath.section) ?? 0
        var cornerRadius = 0.0
        if indexPath.row == 0 || indexPath.row == numberOfRowsInsection - 1 {
            // 只有第一行和最后一行的cell需要设置圆角
            cornerRadius = radius
        }
        
        //cell.contentView负责圆角，cell本身负责阴影
        var mask: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        if indexPath.row == 0 {
            if indexPath.row == numberOfRowsInsection - 1 {
                //只有一行才添加阴影（section中有多个row时暂无法添加阴影）
                if let info = shadowInfo {
                    cell.addShadowLayer(info)
                }
            } else {
                mask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        } else if indexPath.row == numberOfRowsInsection - 1 {
            mask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        //cell本身设置圆角但不裁剪，cell.contentView设置圆角且裁剪
        cell.layer.maskedCorners = mask
        cell.layer.cornerRadius = cornerRadius
        cell.contentView.layer.maskedCorners = mask
        cell.contentView.layer.cornerRadius = cornerRadius
        cell.contentView.layer.masksToBounds = true
        
        //点击效果
        let selectedBackgroundView = UIView(frame: cell.bounds)
        selectedBackgroundView.backgroundColor = selectedBackgroundColor == nil ? UIColor(hexString: "EEEFF1") : selectedBackgroundColor
        selectedBackgroundView.layer.maskedCorners = mask
        selectedBackgroundView.layer.cornerRadius = cornerRadius
        cell.selectedBackgroundView = selectedBackgroundView
    }
}
