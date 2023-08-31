//
//  UIView+Extensions.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit
import SwifterSwift

public extension UIView {
    
    struct HGRectCorner {
        static let topLeft: CACornerMask = .layerMinXMinYCorner
        static let topRight: CACornerMask = .layerMaxXMinYCorner
        static let bottomLeft: CACornerMask = .layerMinXMaxYCorner
        static let bottomRight: CACornerMask = .layerMaxXMaxYCorner
        static let top: CACornerMask = [topLeft, topRight]
        static let bottom: CACornerMask = [bottomLeft, bottomRight]
        static let all: CACornerMask = [topLeft, topRight, bottomLeft, bottomRight]
    }
    
    struct ShadowInfo {
        let shadowColor: UIColor?
        let shadowRadius: CGFloat
        let shadowOffset: CGSize
        let shadowOpacity: Float
        
        public init(shadowColor: UIColor? = UIColor(hexString: "1B85FF"),
             shadowRadius: CGFloat = 15.0,
             shadowOffset: CGSize = CGSize(width: 0, height: 10),
             shadowOpacity: Float = 0.08) {
            self.shadowColor = shadowColor
            self.shadowRadius = shadowRadius
            self.shadowOffset = shadowOffset
            self.shadowOpacity = shadowOpacity
        }
    }
    
    ///添加阴影
    func addShadowLayer(_ info: ShadowInfo = ShadowInfo()) {
        layer.shadowColor = info.shadowColor?.cgColor
        layer.shadowOffset = info.shadowOffset
        layer.shadowRadius = info.shadowRadius
        layer.shadowOpacity = info.shadowOpacity
        layer.masksToBounds = false
        //避免离屏渲染
        if !bounds.isEmpty {
            layer.shadowPath = UIBezierPath(rect: bounds).cgPath            
        }
    }
}

// MARK: - UILabel

public extension UILabel {
    
    /// 快速创建 UILabel
    /// - Parameters:
    ///   - textColor: default .black
    ///   - text: default nil
    ///   - textAlignment: default .left
    ///   - numberOfLines: default 1
    convenience init(font: UIFont,
                     textColor: UIColor? = .black,
                     text: String? = nil,
            textAlignment: NSTextAlignment = .left,
            numberOfLines: Int = 1) {
        self.init(frame: .zero)
        self.text = text
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
        self.font = font
        self.textColor = textColor
    }
    
    
    /// 设置行距
    func textWithLineSpacing(lineSpacing: CGFloat,
                             text: String?,
                             font: UIFont,
                             color: UIColor = .black) {
        guard let _text = text else { return }
        self.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        self.attributedText = NSAttributedString(string: _text, attributes: [.paragraphStyle: style, .foregroundColor: color, .font: font])
    }
    
    /// 将目标 UILabel 的样式属性设置到当前 UILabel 上
    func setTheSameAppearanceAsLabel(_ label: UILabel) {
        self.font = label.font
        self.textColor = label.textColor
        self.backgroundColor = label.backgroundColor
        self.lineBreakMode = label.lineBreakMode
        self.textAlignment = label.textAlignment
    }
}

private var kAssociatedKey_background: Void?
public extension UIStackView {
    ///iOS14以下设置backgroundColor无效
    var hg_backgroundColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &kAssociatedKey_background, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard let color = newValue else { return }
            if #available(iOS 14.0, *) {
                backgroundColor = color
            } else {
                let subView = UIView(frame: bounds)
                subView.backgroundColor = color
                subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                insertSubview(subView, at: 0)
            }
        }
        get {
            let value = objc_getAssociatedObject(self, &kAssociatedKey_background) as? UIColor
            guard let _value = value else {
                return nil
            }
            return _value
        }
    }
}
