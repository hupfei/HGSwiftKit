//
//  HGAutoScrollLabel.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation
import UIKit

public class HGAutoScrollLabel: UILabel {
    /// 滚动速度
    private var speed: CGFloat = 0.5
    /// 重复文字间的间距
    private let space: CGFloat = 30
    private var displayLink: CADisplayLink?
    private var offsetX: CGFloat = 0
    private var textSize: CGSize = .zero
    private var textRepeatCount: Int {
        return textSize.width < bounds.width ? 1 : 2
    }
    private var prevBounds: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.lineBreakMode = .byClipping
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(frame: CGRect, speed: CGFloat = 0.5) {
        super.init(frame: frame)
        self.speed = speed
    }
    
    convenience init(speed: CGFloat) {
        self.init(frame: .zero, speed: speed)
    }
    
    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window {
            displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
            displayLink?.add(to: RunLoop.current, forMode: .common)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        attributedText = attributedText
    }
    
    public override var text: String? {
        didSet {
            offsetX = 0
            textSize = sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            displayLink?.isPaused = !shouldPlayDisplayLink
            setNeedsLayout()
        }
    }

    public override var attributedText: NSAttributedString? {
        didSet {
            offsetX = 0
            textSize = sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            displayLink?.isPaused = !shouldPlayDisplayLink
            setNeedsLayout()
        }
    }
    
    public override func drawText(in rect: CGRect) {
        var textInitialX: CGFloat = 0
        if textAlignment == .center {
            textInitialX = max(0, CGFloatGetCenter(parent: bounds.width, child: textSize.width))
        } else if textAlignment == .right {
            textInitialX = max(0, bounds.width - textSize.width)
        }
        
        for i in 0..<textRepeatCount {
            attributedText?.draw(in: CGRect(x: offsetX + (textSize.width + space) * CGFloat(i) + textInitialX, y: rect.minY + CGFloatGetCenter(parent: rect.height, child: textSize.height), width: textSize.width, height:textSize.height))
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !prevBounds.size.equalTo(bounds.size) {
            offsetX = 0
            displayLink?.isPaused = !shouldPlayDisplayLink
            prevBounds = bounds
        }
    }

    @objc func handleDisplayLink(displayLink: CADisplayLink) {
        if offsetX == 0 {
            displayLink.isPaused = true
            setNeedsDisplay()
            
            let delay: UInt64 = textRepeatCount <= 1 ? 2 : 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + NSEC_PER_MSEC * delay)) {
                self.displayLink?.isPaused = !self.shouldPlayDisplayLink
                if let _displayLink = self.displayLink, !_displayLink.isPaused {
                    self.offsetX -= self.speed
                }
            }
            return
        }
        
        offsetX -= speed
        setNeedsDisplay()

        if -offsetX >= textSize.width + (textRepeatCount > 1 ? space : 0) {
            displayLink.isPaused = true
            let delay: UInt64 = textRepeatCount > 1 ? 2 : 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + NSEC_PER_MSEC * delay)) {
                self.offsetX = 0
                self.handleDisplayLink(displayLink: displayLink)
            }
        }
    }
    
    private var shouldPlayDisplayLink: Bool {
        let result = window != nil && bounds.width > 0 && textSize.width > bounds.width
        if result {
            let rect = window!.convert(frame, from: superview)
            if !window!.bounds.intersects(rect) {
                return false
            }
        }
        return result
    }
}
