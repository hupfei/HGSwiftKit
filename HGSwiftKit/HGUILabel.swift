//
//  HGUILabel.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import UIKit

public class HGUILabel: UILabel {
    /// 圆角保持为高度的 1/2
    var cornerRadiusAdjustsBounds = false
    
    /// 控制label内容的padding
    var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    struct LabelTailViewConfig {
        let tailViewText: String = "展开"
        let tailViewTextColor: UIColor? = UIColor(hexString: "349DFF")
        let tailViewClickedBlock: (() -> Void)?
    }

    ///在 label 的末尾显示一个 展开/更多 的 按钮
    var tailViewConfig: LabelTailViewConfig? {
        didSet {
            if tailView.superview == nil {
                isUserInteractionEnabled = true
                addSubview(tailView)
                setNeedsLayout()
            }
        }
    }
    
    private lazy var tailView: LabelTailView = {
        let view = LabelTailView(frame: .zero, config: tailViewConfig!)
        view.isHidden = true
        view.addTarget(self, action: #selector(tailViewClicked(view:)), for: .touchUpInside)
        return view
    }()
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(CGSize(width: size.width - contentEdgeInsets.horizontal, height: size.height - contentEdgeInsets.vertical))
        newSize.width += contentEdgeInsets.horizontal
        newSize.height += contentEdgeInsets.vertical
        return newSize
    }
    
    public override var intrinsicContentSize: CGSize {
        var preferredMaxLayoutWidth = self.preferredMaxLayoutWidth
        if preferredMaxLayoutWidth <= 0 {
            preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
        }
        return sizeThatFits(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
    }
    
    public override func drawText(in rect: CGRect) {
        var newRect = rect.inset(by: contentEdgeInsets)
        if numberOfLines == 1 && (lineBreakMode == .byWordWrapping || lineBreakMode == .byCharWrapping) {
            newRect = CGRectSetHeight(newRect, height: newRect.height + contentEdgeInsets.top * 2)
        }
        super.drawText(in: newRect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.bounds.isEmpty {
            return
        }
        
        if cornerRadiusAdjustsBounds {
            self.layer.cornerRadius = bounds.height / 2
            self.layer.masksToBounds = true
        }
        
        guard let _ = tailViewConfig, let _attributedText = self.attributedText else {
            return
        }
        
        self.bringSubviewToFront(tailView)
        
        //通过 NSAttributedString 来计算内容的实际高度
        let limitSize = CGSize(width: self.bounds.width - contentEdgeInsets.horizontal, height: CGFLOAT_MAX)
        let string = NSMutableAttributedString(attributedString: _attributedText)
        if self.numberOfLines != 1 && self.lineBreakMode == .byTruncatingTail {
            if let p = string.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                let mp = NSMutableParagraphStyle()
                mp.setParagraphStyle(p)
                mp.lineBreakMode = .byWordWrapping
                string.addAttribute(NSAttributedString.Key.paragraphStyle, value: mp, range: NSRange(location: 0, length: string.length))
            }
        }
        let realSize = string.boundingRect(with: limitSize, options: .usesLineFragmentOrigin, context: nil).size
        let shouldShowTruncatingTailView = realSize.height > self.bounds.height
        tailView.isHidden = !shouldShowTruncatingTailView
        if shouldShowTruncatingTailView {
            let lineHeight = self.font.lineHeight
            tailView.sizeToFit()
            tailView.frame = CGRect(x: self.bounds.width - contentEdgeInsets.right - tailView.frame.width, y: self.bounds.height - contentEdgeInsets.bottom - lineHeight, width: tailView.frame.width, height: lineHeight)
        }
    }
    
    @objc private func tailViewClicked(view: UIControl) {
        if let config = tailViewConfig, let block = config.tailViewClickedBlock {
            block()
        }
    }
}

class LabelTailView: UIControl {
    
    private lazy var gradientMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let config: HGUILabel.LabelTailViewConfig
    private let gradientWidth = 30.0
    private let bgColor = UIColor.white
    
    init(frame: CGRect, config: HGUILabel.LabelTailViewConfig) {
        self.config = config
        super.init(frame: frame)
        self.layer.addSublayer(self.gradientMaskLayer)
        self.addSubview(self.label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superLabel = superview as? UILabel {
            label.setTheSameAppearanceAsLabel(superLabel)
            label.text = config.tailViewText
            label.textColor = config.tailViewTextColor
            gradientMaskLayer.colors = [bgColor.withAlphaComponent(0).cgColor, bgColor.cgColor]
            label.backgroundColor = bgColor
            self.setNeedsLayout()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelSize = label.sizeThatFits(CGSize(width: CGFLOAT_MAX, height: CGFLOAT_MAX))
        return CGSize(width: gradientWidth + labelSize.width, height: labelSize.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskLayer.frame = CGRect(x: 0, y: 0, width: gradientWidth, height: self.bounds.height)
        label.frame = CGRect(x: gradientMaskLayer.frame.maxX, y: 0, width: self.bounds.width - gradientMaskLayer.frame.maxX, height: self.bounds.height)
    }
}
