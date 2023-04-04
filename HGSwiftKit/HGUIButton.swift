//
//  HGUIButton.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import UIKit
import SwifterSwift

enum HGUIButtonImagePosition: Int {
    case top = 0
    case left
    case bottom
    case right
}

public class HGUIButton: UIButton {
    /// 按钮里图标和文字的相对位置
    var imagePosition: HGUIButtonImagePosition = .left {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 按钮里图标和文字之间的间隔
    var spacingBetweenImageAndTitle: CGFloat = 5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 圆角（cornerRadiusAdjustsBounds为 true 则设置无效）
    var buttonCornerRadius: CGFloat = 0 {
        didSet {
            if (!cornerRadiusAdjustsBounds) {
                layer.cornerRadius = buttonCornerRadius
            }
            self.setNeedsLayout()
        }
    }
    /// 圆角保持为高度的 1/2
    var cornerRadiusAdjustsBounds: Bool = false
    
    ///背景渐变色背景
    private var gradientLayer: CAGradientLayer?
    
    /// 按钮点击时的背景色
    var highlightedBackgroundColor: UIColor?
    
    private var highlightedBackgroundLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentEdgeInsets = UIEdgeInsets(top: CGFloat.leastNormalMagnitude, left: 0, bottom: CGFloat.leastNormalMagnitude, right: 0)
        didInitialize()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialize()
    }
    
    private func didInitialize() {
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
    }
    
    /// 快速创建一个圆角 button
    /// - Parameters:
    ///   - cornerRadiusAdjustsBounds: true-圆角为高度1/2
    init(withFillColor fillColor: UIColor?, titleColor: UIColor?, title: String? = nil, cornerRadiusAdjustsBounds: Bool = true) {
        super.init(frame: .zero)
        
        self.cornerRadiusAdjustsBounds = cornerRadiusAdjustsBounds
        self.backgroundColor = fillColor
        self.setTitleColor(titleColor, for: .normal)
        self.setTitle(title, for: .normal)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var btnSize = size
        if bounds.size.equalTo(size) || (size.width <= 0 || size.height <= 0) {
            btnSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }
        
        let isImageViewShowing = currentImage != nil
        let isTitleLabelShowing = currentTitle != nil || currentAttributedTitle != nil
        var imageTotalSize = CGSize.zero
        var titleTotalSize = CGSize.zero
        let spacingBetweenImageAndTitle = (isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0)
        var resultSize = CGSize.zero
        let contentLimitSize = CGSize(width: btnSize.width - contentEdgeInsets.left - contentEdgeInsets.right, height: btnSize.height - contentEdgeInsets.top - contentEdgeInsets.bottom)
        
        switch imagePosition {
        case .top, .bottom:
            if isImageViewShowing {
                let imageLimitWidth = contentLimitSize.width - imageEdgeInsets.left - imageEdgeInsets.right
                var imageSize = currentImage!.size
                if let _ = imageView!.image {
                    imageSize = imageView!.sizeThatFits(CGSize(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude))
                }
                imageSize.width = min(imageSize.width, imageLimitWidth)
                imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.left + imageEdgeInsets.right, height: imageSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom)
            }
            if isTitleLabelShowing {
                let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.left - titleEdgeInsets.right, height: contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.top - titleEdgeInsets.bottom)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.height = min(titleSize.height, titleLimitSize.height)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: titleSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
            }
            resultSize.width = contentEdgeInsets.left + contentEdgeInsets.right
            resultSize.width += max(imageTotalSize.width, titleTotalSize.width)
            resultSize.height = contentEdgeInsets.top + contentEdgeInsets.bottom + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
        case .left, .right:
            if isImageViewShowing {
                let imageLimitHeight = contentLimitSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom
                var imageSize = currentImage!.size
                if let _ = imageView!.image {
                    imageSize = imageView!.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: imageLimitHeight))
                }
                imageSize.height = min(imageSize.height, imageLimitHeight)
                imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.left + imageEdgeInsets.right, height: imageSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom)
            }
            if isTitleLabelShowing {
                let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.left - titleEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle, height: contentLimitSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.height = min(titleSize.height, titleLimitSize.height)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: titleSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
            }
            resultSize.width = contentEdgeInsets.left + contentEdgeInsets.right + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
            resultSize.height = contentEdgeInsets.top + contentEdgeInsets.bottom
            resultSize.height += max(imageTotalSize.height, titleTotalSize.height)
        }
        return resultSize
    }

    public override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.isEmpty {
            return
        }
        
        if cornerRadiusAdjustsBounds {
            layer.cornerRadius = bounds.height / 2
            layer.masksToBounds = true
        }
        
        let isImageViewShowing = currentImage != nil
        let isTitleLabelShowing = currentTitle != nil || currentAttributedTitle != nil
        var imageLimitSize = CGSize.zero
        var titleLimitSize = CGSize.zero
        var imageTotalSize = CGSize.zero
        var titleTotalSize = CGSize.zero
        let spacingBetweenImageAndTitle = (isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0)
        var imageFrame = CGRect.zero
        var titleFrame = CGRect.zero
        let contentSize = CGSize(width: bounds.width - contentEdgeInsets.left - contentEdgeInsets.right, height: bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom)
        if isImageViewShowing {
            imageLimitSize = CGSize(width: contentSize.width - imageEdgeInsets.left - imageEdgeInsets.right, height: contentSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom)
            var imageSize = currentImage!.size
            if let _ = imageView!.image {
                imageSize = imageView!.sizeThatFits(imageLimitSize)
            }
            imageSize.width = min(imageLimitSize.width, imageSize.width)
            imageSize.height = min(imageLimitSize.height, imageSize.height)
            imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.left + imageEdgeInsets.right, height: imageSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom)
            imageFrame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.left + imageEdgeInsets.right, height: imageSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom)
        }
        if imagePosition == .top || imagePosition == .bottom {
            if isTitleLabelShowing {
                titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.left - titleEdgeInsets.right, height: contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.top - titleEdgeInsets.bottom)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.width = min(titleLimitSize.width, titleSize.width)
                titleSize.height = min(titleLimitSize.height, titleSize.height)
                titleFrame = CGRect(x: 0, y: 0, width: titleSize.width, height: titleSize.height)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: titleSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
            }
            
            switch contentHorizontalAlignment {
            case .left:
                imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left) : titleFrame
            case .center:
                imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left + CGFloatGetCenter(parent: imageLimitSize.width, child: imageFrame.width)) : imageFrame
                titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left + CGFloatGetCenter(parent: titleLimitSize.width, child: titleFrame.width)) : titleFrame
            case .right:
                imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.width) : titleFrame
            case .fill:
                if isImageViewShowing {
                    imageFrame = CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left)
                    imageFrame = CGRectSetWidth(imageFrame, width: imageLimitSize.width)
                }
                if isTitleLabelShowing {
                    titleFrame = CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left)
                    titleFrame = CGRectSetWidth(titleFrame, width: titleLimitSize.width)
                }
            default:
                break
            }
            
            if imagePosition == .top {
                switch contentVerticalAlignment {
                case .top:
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                case .center:
                    let contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
                    let minY = CGFloatGetCenter(parent: contentSize.height, child: contentHeight) + contentEdgeInsets.top
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: minY + imageEdgeInsets.top) : imageFrame
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: minY + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                case .bottom:
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: bounds.height - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                        titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                        titleFrame = isTitleLabelShowing ? CGRectSetHeight(titleFrame, height: bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY) : titleFrame
                        
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetY(imageFrame, y: contentEdgeInsets.top + imageEdgeInsets.top)
                        imageFrame = CGRectSetHeight(imageFrame, height: contentSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom)
                    } else {
                        titleFrame = CGRectSetY(titleFrame, y: contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = CGRectSetHeight(titleFrame, height: contentSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
                    }
                default :
                    break
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: contentEdgeInsets.top + titleEdgeInsets.top) : titleFrame
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top) : imageFrame
                case .center:
                    let contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle
                    let minY = CGFloatGetCenter(parent: contentSize.height, child: contentHeight) + contentEdgeInsets.top
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: minY + titleEdgeInsets.top) : titleFrame
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: minY + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top) : imageFrame
                case .bottom:
                    imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                    titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
                case .fill:
                    if (isImageViewShowing && isTitleLabelShowing) {
                        imageFrame = CGRectSetY(imageFrame, y: bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height)
                        titleFrame = CGRectSetY(titleFrame, y: contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = CGRectSetHeight(titleFrame, height: bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.minY)
                        
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetY(imageFrame, y: contentEdgeInsets.top + imageEdgeInsets.top)
                        imageFrame = CGRectSetHeight(imageFrame, height: contentSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom)
                    } else {
                        titleFrame = CGRectSetY(titleFrame, y: contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = CGRectSetHeight(titleFrame, height: contentSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
                    }
                default:
                    break
                }
            }

            imageView?.frame = imageFrame
            titleLabel?.frame = titleFrame
        } else if imagePosition == .left || imagePosition == .right {
            if isTitleLabelShowing {
                titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.left - titleEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle, height: contentSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.width = min(titleLimitSize.width, titleSize.width)
                titleSize.height = min(titleLimitSize.height, titleSize.height)
                titleFrame = CGRect(origin: CGPoint.zero, size: titleSize)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: titleSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
            }
            
            switch contentVerticalAlignment {
            case .top:
                imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: contentEdgeInsets.top + titleEdgeInsets.top) : titleFrame
            case .center:
                imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: contentEdgeInsets.top + CGFloatGetCenter(parent: contentSize.height, child: imageFrame.height) + imageEdgeInsets.top) : imageFrame
                titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: contentEdgeInsets.top + CGFloatGetCenter(parent: contentSize.height, child: titleFrame.height) + titleEdgeInsets.top) : titleFrame
            case .bottom:
                imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, y: bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, y: bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
            case .fill:
                    if isImageViewShowing {
                        imageFrame = CGRectSetY(imageFrame, y: contentEdgeInsets.top + imageEdgeInsets.top)
                        imageFrame = CGRectSetHeight(imageFrame, height: contentSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom)
                    }
                    if isTitleLabelShowing {
                        titleFrame = CGRectSetY(titleFrame, y: contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = CGRectSetHeight(titleFrame, height: contentSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
                    }
            default:
                break
            }
            
            if imagePosition == .left {
                switch contentHorizontalAlignment {
                case .left:
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + CGFloatGetCenter(parent: contentSize.width, child: contentWidth)
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: minX + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: minX + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                case .right:
                    if imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width {
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                    } else {
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.width) : titleFrame
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: bounds.width - contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + imageEdgeInsets.left) : imageFrame
                    }
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        imageFrame = CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left)
                        titleFrame = CGRectSetX(titleFrame, x: contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left)
                        titleFrame = CGRectSetWidth(titleFrame, width: bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.minX)
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left)
                        imageFrame = CGRectSetWidth(imageFrame, width: contentSize.width - imageEdgeInsets.left - imageEdgeInsets.right)
                    } else {
                        titleFrame = CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = CGRectSetWidth(titleFrame, width: contentSize.width - titleEdgeInsets.left - titleEdgeInsets.right)
                    }
                default:
                    break
                }
            } else {
                switch contentHorizontalAlignment {
                case .left:
                    if imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width {
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + titleEdgeInsets.left) : titleFrame
                    } else {
                        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left) : titleFrame
                        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + imageEdgeInsets.left) : imageFrame
                    }
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + CGFloatGetCenter(parent: contentSize.width, child: contentWidth)
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: minX + titleEdgeInsets.left) : titleFrame
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: minX + titleTotalSize.width + spacingBetweenImageAndTitle + imageEdgeInsets.left) : imageFrame
                case .right:
                    imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, x: bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                    titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, x: bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleEdgeInsets.right - titleFrame.width) : titleFrame
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        imageFrame = CGRectSetX(imageFrame, x: bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width)
                        titleFrame = CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = CGRectSetWidth(titleFrame, width: imageFrame.minX - imageEdgeInsets.left - spacingBetweenImageAndTitle - titleEdgeInsets.right - titleFrame.minX)
                        
                    } else if (isImageViewShowing) {
                        imageFrame = CGRectSetX(imageFrame, x: contentEdgeInsets.left + imageEdgeInsets.left)
                        imageFrame = CGRectSetWidth(imageFrame, width: contentSize.width - imageEdgeInsets.left - imageEdgeInsets.right)
                    } else {
                        titleFrame = CGRectSetX(titleFrame, x: contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = CGRectSetWidth(titleFrame, width: contentSize.width - titleEdgeInsets.left - titleEdgeInsets.right)
                    }
                default:
                    break
                }
            }

            imageView?.frame = imageFrame
            titleLabel?.frame = titleFrame
            
            if let _ = gradientLayer {
                gradientLayer?.frame = bounds
            }
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            if let color = highlightedBackgroundColor {
                if highlightedBackgroundLayer == nil {
                    highlightedBackgroundLayer = CALayer()
                    highlightedBackgroundLayer?.frame = bounds
                    highlightedBackgroundLayer?.cornerRadius = layer.cornerRadius
                    highlightedBackgroundLayer?.maskedCorners = layer.maskedCorners
                    layer.insertSublayer(highlightedBackgroundLayer!, at: 0)
                }
                highlightedBackgroundLayer?.backgroundColor = isHighlighted ? color.cgColor : UIColor.clear.cgColor
            } else {
                alpha = isHighlighted ? 0.5 : 1
            }
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    func addgradientLayer(colors: [UIColor] = [UIColor(hexString: "#369EFF")!,
                                               UIColor(hexString: "#1C86FF")!,
                                               UIColor(hexString: "#006DFF")!],
                          startPoint: CGPoint = CGPoint(x: 0, y: 0),
                          endPoint: CGPoint = CGPoint(x: 0, y: 1)) {
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors =  colors.map { $0.cgColor }
        gradientLayer?.startPoint = startPoint
        gradientLayer?.endPoint = endPoint
        gradientLayer?.type = .axial
        self.layer.insertSublayer(gradientLayer!, at: 0)
        self.layoutIfNeeded()
    }
}
