//
//  HGBadgeProtocol.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit
import SnapKit

public enum HGBadgeStyle {
    case dot
    case number(value: Int)
}

public protocol HGBadgeProtocol {
    /// 默认字号：11
    var badgeFont: UIFont { set get }
    /// 背景色：红色
    var badgeBackgroundColor: UIColor { set get }
    /// 字体颜色：白色
    var badgeTextColor: UIColor { set get }
    /// 中心偏移量
    var badgeCenterOffset: CGPoint { set get }
    
    func showBadge(style: HGBadgeStyle)
    func clearBadge()
}

fileprivate var badgeKey: UInt8 = 0
extension UIView: HGBadgeProtocol {
    
    public var badgeFont: UIFont {
        set {
            badgeInit()
            badgeLabel.font = newValue
        }
        get { .boldSystemFont(ofSize: 11) }
    }
    
    public var badgeBackgroundColor: UIColor {
        set {
            badgeInit()
            badgeLabel.backgroundColor = newValue
        }
        get { .red }
    }
    
    public var badgeTextColor: UIColor {
        set {
            badgeInit()
            badgeLabel.textColor = newValue
        }
        get { .white }
    }
    
    public var badgeCenterOffset: CGPoint {
        set {
            badgeInit()
            badgeLabel.snp.updateConstraints { make in
                make.centerY.equalTo(self.snp.top).offset(newValue.y)
                make.centerX.equalTo(self.snp.right).offset(newValue.x)
            }
        }
        get { .zero }
    }
    
    public func clearBadge() {
        badgeLabel.isHidden = true
    }
    
    public func showBadge(style: HGBadgeStyle) {
        badgeInit()
        badgeLabel.isHidden = false
        switch style {
        case .dot:
            badgeLabel.text = ""
            badgeLabel.snp.updateConstraints { make in
                make.size.equalTo(CGSize(width: dotSize, height: dotSize))
            }
        case .number(let value):
            let text = value <= maximumBadgeNumber ? "\(value)" : "\(maximumBadgeNumber)+"
            badgeLabel.text = text
            badgeLabel.sizeToFit()
            badgeLabel.layer.cornerRadius = badgeLabel.height / 2
            badgeLabel.snp.updateConstraints { make in
                make.size.equalTo(CGSize(width: max(badgeLabel.height, badgeLabel.width), height: badgeLabel.height))
            }
        }
    }
    
    // MARK: - private method
    
    private var dotSize: CGFloat { 8 }
    private var maximumBadgeNumber: Int { 99 }

    private func badgeInit() {
        if badgeLabel.superview == nil {
            self.addSubview(badgeLabel)
            self.bringSubviewToFront(badgeLabel)
            self.clipsToBounds = false
            badgeLabel.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: dotSize, height: dotSize))
                make.centerY.equalTo(self.snp.top).offset(badgeCenterOffset.y)
                make.centerX.equalTo(self.snp.right).offset(badgeCenterOffset.x)
            }
        }
    }
    
    private var badgeLabel: UILabel {
        get {
            if let value = objc_getAssociatedObject(self, &badgeKey) as? UILabel {
                return value
            }
            
            let label = HGUILabel()
            label.font = badgeFont
            label.textColor = badgeTextColor
            label.backgroundColor = badgeBackgroundColor
            label.textAlignment = .center
            label.isHidden = true
            label.clipsToBounds = true
            label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
            objc_setAssociatedObject(self, &badgeKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return label
        }

        set {
            objc_setAssociatedObject(self, &badgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIBarButtonItem: HGBadgeProtocol {
    
    public var badgeFont: UIFont {
        get { barButtonItemContentView.badgeFont }
        set { barButtonItemContentView.badgeFont = newValue }
    }
    
    public var badgeBackgroundColor: UIColor {
        get { barButtonItemContentView.badgeBackgroundColor }
        set { barButtonItemContentView.badgeBackgroundColor = newValue }
    }
    
    public var badgeTextColor: UIColor {
        get { barButtonItemContentView.badgeTextColor }
        set { barButtonItemContentView.badgeTextColor = newValue }
    }
    
    public var badgeCenterOffset: CGPoint {
        get { barButtonItemContentView.badgeCenterOffset }
        set { barButtonItemContentView.badgeCenterOffset = newValue }
    }
    
    public func clearBadge() {
        barButtonItemContentView.clearBadge()
    }
    
    public func showBadge(style: HGBadgeStyle) {
        barButtonItemContentView.showBadge(style: style)
    }
    
    // MARK: - private method
    private var barButtonItemContentView: UIView {
        return (self.value(forKey: "_view") as? UIView) ?? UIView()
    }
}
